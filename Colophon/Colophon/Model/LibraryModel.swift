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

/// An external change to the open file awaiting the user's Reload / Ignore decision (M1.2).
struct PendingExternalChange: Equatable {
    let url: URL
    let diskContents: String
}

/// Thrown by `writeAndRecord` when the on-disk file changed under us — the write is refused so a
/// stale buffer never clobbers an external edit.
private enum WriteAborted: Error { case externalChange }

@MainActor
final class LibraryModel: ObservableObject {
    // Library
    @Published var folderURL: URL?
    @Published var fileTree: [FileNode] = []
    @Published var selectedFile: URL? {
        didSet {
            guard selectedFile != oldValue, !isRevertingSelection else { return }
            // Flush unsaved edits of the file we're leaving before switching away.
            if let doc = document, buffer.string != doc.onDiskText {
                do {
                    try writeAndRecord(buffer.string, to: doc.url)
                } catch {
                    // The departing file changed on disk under us — flushing would clobber it, so
                    // do NOT drop its unsaved edits (BLOCKER: silent switch-flush loss). Veto the
                    // switch: stay on the file and let the banner (pendingExternalChange) resolve it.
                    isRevertingSelection = true
                    selectedFile = oldValue
                    isRevertingSelection = false
                    return
                }
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

    /// Set when a coordinated write was refused because the open file changed on disk under us
    /// (or a reconcile/presenter observed an external change while the buffer is dirty). The view
    /// surfaces a non-modal banner (M1.2 step 7); until it's resolved, autosave/save are gated off.
    @Published private(set) var pendingExternalChange: PendingExternalChange?

    /// Set when the open file was deleted (or renamed) on disk under us. The view surfaces a
    /// "deleted on disk" banner; autosave/save are gated so we NEVER silently recreate a vanished
    /// file — the user restores it explicitly (M1.2 step 8).
    @Published private(set) var deletedFileURL: URL?

    /// True when the buffer differs from what's on disk.
    var isDirty: Bool {
        guard let document else { return false }
        return buffer.string != document.onDiskText
    }

    private var accessedFolder: URL?
    private var isSwitching = false
    private var isRevertingSelection = false  // re-entrancy guard for a vetoed file switch
    private var cancellables = Set<AnyCancellable>()
    /// SHA-256 of the bytes we last wrote (or accepted from disk) per file — the self-write
    /// sentinel (D-M1-9). Recorded wherever we accept disk truth (write + load + external reload);
    /// the read-before-write guard compares a coordinated re-read against it.
    private var lastWrittenHash: [URL: Data] = [:]
    /// Watches the open file for external changes (M1.2 / D-M1-15). Nil when nothing is open.
    private var presenter: DocumentPresenter?

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
        // Reconcile the open file against disk when we regain focus / foreground — the net for an
        // external change the presenter might have missed while we weren't frontmost.
        for name in [
            NSApplication.didBecomeActiveNotification, NSWindow.didBecomeKeyNotification,
        ] {
            NotificationCenter.default.publisher(for: name)
                .sink { [weak self] _ in MainActor.assumeIsolated { self?.reconcileOpenDocument() }
                }
                .store(in: &cancellables)
        }
    }

    /// Re-check the open file against disk (content hash, never mtime) and apply any external
    /// change — the belt-and-suspenders net to the presenter, run on window focus / app foreground.
    func reconcileOpenDocument() {
        guard let doc = document else { return }
        if !FileManager.default.fileExists(atPath: doc.url.path) {
            deletedFileURL = doc.url  // deleted / renamed under us
            return
        }
        guard let contents = try? CoordinatedFileIO.read(doc.url) else { return }
        applyExternalChange(url: doc.url, newContents: contents)
    }

    /// The presenter reports the open file was deleted (or renamed) on disk (M1.2 step 8).
    func handleExternalRemoval(url: URL) {
        guard url == document?.url else { return }
        deletedFileURL = url
    }

    /// Recreate a deleted-on-disk file from the current buffer (the banner's "Save to Restore").
    /// Writes unguarded — the file is gone, so this deliberately creates it.
    func restoreDeleted() {
        guard let url = deletedFileURL, url == document?.url else { return }
        deletedFileURL = nil
        do {
            lastWrittenHash[url] = try CoordinatedFileIO.write(buffer.string, to: url)
            document = Document(url: url, onDiskText: buffer.string)
        } catch {
            lastError = String(
                localized:
                    "Couldn't restore \"\(url.lastPathComponent)\": \(error.localizedDescription)"
            )
        }
    }

    // MARK: - Resolve a pending external change (the banner's actions)

    /// Take the disk version, discarding the buffer's unsaved edits (recoverable with one Cmd-Z —
    /// reloadPreservingSelection registers a single undo frame). Advances the snapshot + fingerprint.
    func reloadFromPending() {
        guard let pending = pendingExternalChange, pending.url == document?.url else { return }
        _ = buffer.reloadPreservingSelection(pending.diskContents)
        document = Document(url: pending.url, onDiskText: pending.diskContents)
        lastWrittenHash[pending.url] = CoordinatedFileIO.hash(pending.diskContents)  // accept disk
        pendingExternalChange = nil
    }

    /// Keep the buffer's edits and dismiss the banner. Re-baselines the fingerprint to the current
    /// disk contents so (a) the SAME external change doesn't re-nag and (b) a later save is permitted
    /// (last-writer-wins — the user's edits overwrite disk; never a silent merge). The document
    /// stays dirty.
    func ignorePending() {
        guard let pending = pendingExternalChange else { return }
        lastWrittenHash[pending.url] = CoordinatedFileIO.hash(pending.diskContents)
        pendingExternalChange = nil
    }

    // MARK: - Library

    /// Open a folder the user chose in the view (L1 presents the picker; the model stays
    /// UI-free). The URL is expected to be security-scoped.
    func openFolder(_ url: URL) {
        setPresenter(for: nil)  // stop watching before the old folder's security scope is dropped
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
        pendingExternalChange = nil  // fresh file — clear any prior file's pending state
        deletedFileURL = nil
        guard let url = selectedFile else {
            buffer.load("")
            document = nil
            setPresenter(for: nil)
            return
        }
        do {
            let contents = try MarkdownFileIO.read(url)
            buffer.load(contents)
            document = Document(url: url, onDiskText: contents)
            lastWrittenHash[url] = CoordinatedFileIO.hash(contents)  // accept disk truth
            setPresenter(for: url)  // watch the open file for external changes
        } catch MarkdownFileIO.IOError.notValidUTF8 {
            buffer.load("")
            document = nil
            setPresenter(for: nil)
            lastError = String(
                localized:
                    "\"\(url.lastPathComponent)\" isn't valid UTF-8. Colophon won't open it to avoid corrupting the file."
            )
        } catch {
            buffer.load("")
            document = nil
            setPresenter(for: nil)
            lastError = String(
                localized:
                    "Couldn't open \"\(url.lastPathComponent)\": \(error.localizedDescription)"
            )
        }
    }

    /// (Re)register the single-file presenter for the open document, or tear it down (url == nil).
    /// Stopped before the folder's security scope is dropped (openFolder) so no coordinated read
    /// outlives its scope.
    private func setPresenter(for url: URL?) {
        presenter?.stop()
        presenter = nil
        guard let url else { return }
        presenter = DocumentPresenter(
            url: url,
            onExternalChange: { [weak self] contents in
                MainActor.assumeIsolated {
                    self?.applyExternalChange(url: url, newContents: contents)
                }
            },
            onRemoved: { [weak self] in
                MainActor.assumeIsolated { self?.handleExternalRemoval(url: url) }
            })
    }

    /// Deliver an external on-disk change to the open file (from the presenter or a reconcile scan).
    /// If the incoming bytes are really our own last write, ignore it (SHA-256 dedup). Otherwise a
    /// CLEAN document silently reloads in place (caret preserved); a DIRTY document surfaces a
    /// non-modal banner so we never clobber the user's unsaved edits.
    func applyExternalChange(url: URL, newContents: String) {
        guard url == document?.url else { return }
        guard CoordinatedFileIO.hash(newContents) != lastWrittenHash[url] else { return }
        if buffer.string == document?.onDiskText {
            if buffer.reloadPreservingSelection(newContents) {
                document = Document(url: url, onDiskText: newContents)
                lastWrittenHash[url] = CoordinatedFileIO.hash(newContents)  // accept disk truth
            } else {
                // Editor is mid-IME-composition — defer via the banner, don't mutate under marked text.
                pendingExternalChange = PendingExternalChange(url: url, diskContents: newContents)
            }
        } else {
            pendingExternalChange = PendingExternalChange(url: url, diskContents: newContents)
        }
    }

    /// The single write choke point (M1.2): a coordinated byte-exact atomic write GUARDED by a
    /// read-before-write check. If the file still matches what we last wrote, write and record the
    /// new SHA-256. If it changed on disk under us, DON'T clobber it — record a
    /// `pendingExternalChange` (the view surfaces a banner) and throw so the caller stops. All
    /// three write sites (save, autosave, switch-flush) route through here.
    private func writeAndRecord(_ text: String, to url: URL) throws {
        switch try CoordinatedFileIO.writeGuarded(text, to: url, expected: lastWrittenHash[url]) {
        case .wrote(let fingerprint):
            lastWrittenHash[url] = fingerprint
        case .externalChange(let diskContents):
            pendingExternalChange = PendingExternalChange(url: url, diskContents: diskContents)
            throw WriteAborted.externalChange
        case .removed:
            deletedFileURL = url  // vanished under us — never silently recreate; surface a banner
            throw WriteAborted.externalChange
        }
    }

    func save() {
        // Nothing to write when the buffer already matches disk — makes a redundant ⌘S a no-op
        // (a rapid ⌘S burst was doing one coordinated read+write per press and janking the UI).
        guard let doc = document, pendingExternalChange == nil, deletedFileURL == nil,
            buffer.string != doc.onDiskText
        else { return }
        do {
            try writeAndRecord(buffer.string, to: doc.url)
            document = Document(url: doc.url, onDiskText: buffer.string)
        } catch is WriteAborted {
            // The file changed on disk under us — pendingExternalChange is set; the banner resolves it.
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
        guard !isSwitching, pendingExternalChange == nil, deletedFileURL == nil, let doc = document,
            buffer.string != doc.onDiskText
        else { return }
        do {
            try writeAndRecord(buffer.string, to: doc.url)
            document = Document(url: doc.url, onDiskText: buffer.string)
        } catch {
            // Intentionally silent — a WriteAborted sets pendingExternalChange; other errors retry.
        }
    }
}
