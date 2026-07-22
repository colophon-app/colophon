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
//  switching files — every write byte-exact and atomic (MarkdownFileIO).
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
            if let doc = document, text != doc.onDiskText {
                try? MarkdownFileIO.write(text, to: doc.url)
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
    /// The live editable buffer the editor binds to.
    @Published var text: String = ""
    /// The currently open file's context (URL + on-disk snapshot). Nil when nothing is open.
    @Published private(set) var document: Document?
    /// A user-facing error for the view to surface (cleared when dismissed). The model never
    /// presents an alert itself.
    @Published var lastError: String?

    /// True when the buffer differs from what's on disk.
    var isDirty: Bool {
        guard let document else { return false }
        return text != document.onDiskText
    }

    private var accessedFolder: URL?
    private var isSwitching = false
    private var cancellables = Set<AnyCancellable>()

    init() {
        // Autosave triggers: idle after edits, app resigns active, app terminates.
        $text
            .dropFirst()
            .debounce(for: .seconds(1.5), scheduler: RunLoop.main)
            .sink { [weak self] _ in MainActor.assumeIsolated { self?.autosaveIfNeeded() } }
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
        text = ""
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
            text = ""
            document = nil
            return
        }
        do {
            let contents = try MarkdownFileIO.read(url)
            text = contents
            document = Document(url: url, onDiskText: contents)
        } catch MarkdownFileIO.IOError.notValidUTF8 {
            text = ""
            document = nil
            lastError = String(
                localized:
                    "\"\(url.lastPathComponent)\" isn't valid UTF-8. Colophon won't open it to avoid corrupting the file."
            )
        } catch {
            text = ""
            document = nil
            lastError = String(
                localized:
                    "Couldn't open \"\(url.lastPathComponent)\": \(error.localizedDescription)"
            )
        }
    }

    func save() {
        guard let doc = document else { return }
        do {
            try MarkdownFileIO.write(text, to: doc.url)
            document = Document(url: doc.url, onDiskText: text)
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
        guard !isSwitching, let doc = document, text != doc.onDiskText else { return }
        do {
            try MarkdownFileIO.write(text, to: doc.url)
            document = Document(url: doc.url, onDiskText: text)
        } catch {
            // Intentionally silent — see doc comment.
        }
    }
}
