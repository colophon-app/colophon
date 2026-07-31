// SPDX-License-Identifier: Apache-2.0
//
//  LibraryModel.swift
//  Colophon
//
//  L2 model: a folder is the library. Open a folder, list its Markdown files, load one
//  (strict UTF-8), edit, autosave. No proprietary state.
//
//  L2 isolation (architecture §1.2, §2.1): the model owns state and intents but does NOT
//  present UI. The folder picker and error alerts live in L1 (the view); the model exposes
//  `openFolder(_:)` for a chosen URL and publishes `lastError` for the view to surface.
//  (AppKit is imported only for app-lifecycle notifications, not for any UI presentation.)
//
//  Library vs Document (architecture §2.2): the library owns the folder + file list; the
//  currently open file is a `Document` (its URL + on-disk snapshot). `text` is the live
//  editable buffer; `text != document.onDiskText` is the dirty signal.
//
//  Autosave: edits are flushed after a short idle, on resign-active / terminate, and before
//  switching files. Every write routes through the single `writeAndRecord` choke point — byte-
//  exact, atomic, and coordinated (CoordinatedFileIO / D-M1-8), and fingerprinted (SHA-256) so
//  an external change can be told from our own write (M1.2 / D-M1-9).
//

import AppKit
import Combine
import SwiftUI

@MainActor
final class LibraryModel: ObservableObject {
    // Library
    @Published var folderURL: URL?
    @Published var fileTree: [FileNode] = []
    @Published var selectedFile: URL? {
        didSet {
            guard selectedFile != oldValue else { return }
            // Flush unsaved edits of the file we're leaving before switching away.
            if let doc = document, buffer.string != doc.onDiskText {
                try? writeAndRecord(buffer.string, to: doc.url)
            }
            // The List sets this during a SwiftUI view update; loading here would publish
            // `text` mid-update ("Publishing changes from within view updates"). Defer to
            // the next runloop turn so the publish happens outside the update. `isSwitching`
            // suppresses autosave in the gap so a stale `text` can't be written to the new
            // file's URL.
            isSwitching = true
            DispatchQueue.main.async { [weak self] in self?.loadSelected() }
        }
    }

    // Open document
    /// The live editable text — L2's single in-memory source of truth (architecture §2.2). The
    /// editor shares this buffer's NSTextStorage, so there is no per-keystroke @Binding round-trip.
    let buffer = TextBuffer()
    /// The currently open file's context (URL + on-disk snapshot). Nil when nothing is open.
    @Published private(set) var document: Document?
    /// A user-facing error for the view to surface (cleared when dismissed). The model never
    /// presents an alert itself.
    @Published var lastError: String?

    /// True when the buffer differs from what's on disk.
    var isDirty: Bool {
        guard let document else { return false }
        return buffer.string != document.onDiskText
    }

    private var accessedFolder: URL?
    private var isSwitching = false
    private var cancellables = Set<AnyCancellable>()
    /// SHA-256 of the bytes we last wrote (or accepted from disk) per file — the self-write
    /// sentinel (D-M1-9). Recorded wherever we accept disk truth (write + load); the M1.2
    /// read-before-write guard (next step) compares a coordinated re-read against it.
    private var lastWrittenHash: [URL: Data] = [:]

    init() {
        // Autosave triggers: idle after edits, app resigns active, app terminates. The buffer
        // emits `changed` on real edits only (never on load), so no dropFirst() is needed —
        // dropping the first signal would swallow a single-edit session's idle autosave.
        buffer.changed
            .debounce(for: .seconds(1.5), scheduler: RunLoop.main)
            .sink { [weak self] in MainActor.assumeIsolated { self?.autosaveIfNeeded() } }
            .store(in: &cancellables)
        for name in [
            NSApplication.willResignActiveNotification, NSApplication.willTerminateNotification,
        ] {
            NotificationCenter.default.publisher(for: name)
                .sink { [weak self] _ in MainActor.assumeIsolated { self?.autosaveIfNeeded() } }
                .store(in: &cancellables)
        }
    }

    // MARK: - Library

    /// Open a folder the user chose in the view (L1 presents the picker; the model stays
    /// UI-free). The URL is expected to be security-scoped.
    func openFolder(_ url: URL) {
        accessedFolder?.stopAccessingSecurityScopedResource()
        _ = url.startAccessingSecurityScopedResource()
        accessedFolder = url

        folderURL = url
        selectedFile = nil
        buffer.load("")
        document = nil
        refreshFiles()
    }

    func refreshFiles() {
        guard let folderURL else {
            fileTree = []
            return
        }
        fileTree = FileTreeBuilder.build(root: folderURL)
    }

    // MARK: - Document

    private func loadSelected() {
        defer { isSwitching = false }
        guard let url = selectedFile else {
            buffer.load("")
            document = nil
            return
        }
        do {
            let contents = try MarkdownFileIO.read(url)
            buffer.load(contents)
            document = Document(url: url, onDiskText: contents)
            lastWrittenHash[url] = CoordinatedFileIO.hash(contents)  // accept disk truth
        } catch MarkdownFileIO.IOError.notValidUTF8 {
            buffer.load("")
            document = nil
            lastError = String(
                localized:
                    "\"\(url.lastPathComponent)\" isn't valid UTF-8. Colophon won't open it to avoid corrupting the file."
            )
        } catch {
            buffer.load("")
            document = nil
            lastError = String(
                localized:
                    "Couldn't open \"\(url.lastPathComponent)\": \(error.localizedDescription)"
            )
        }
    }

    /// The single write choke point (M1.2): coordinated byte-exact atomic write + record the
    /// SHA-256 of the bytes written, so an incoming change event can tell this self-write from an
    /// external one. All three write sites (save, autosave, switch-flush) route through here.
    private func writeAndRecord(_ text: String, to url: URL) throws {
        lastWrittenHash[url] = try CoordinatedFileIO.write(text, to: url)
    }

    func save() {
        guard let doc = document else { return }
        do {
            try writeAndRecord(buffer.string, to: doc.url)
            document = Document(url: doc.url, onDiskText: buffer.string)
        } catch {
            lastError = String(
                localized: "Couldn't save \"\(doc.displayName)\": \(error.localizedDescription)"
            )
        }
    }

    /// Save on idle / focus loss / quit. Silent on failure (retries on the next edit);
    /// explicit `save()` surfaces the error. Skipped mid-switch so a stale `text` is never
    /// written to the newly selected file.
    private func autosaveIfNeeded() {
        guard !isSwitching, let doc = document, buffer.string != doc.onDiskText else { return }
        do {
            try writeAndRecord(buffer.string, to: doc.url)
            document = Document(url: doc.url, onDiskText: buffer.string)
        } catch {
            // Intentionally silent — see doc comment.
        }
    }
}
