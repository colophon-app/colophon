// SPDX-License-Identifier: Apache-2.0
//
//  LibraryModel.swift
//  Colophon
//
//  M0 skeleton: a folder is the library. Open a folder, list its Markdown files,
//  load one (strict UTF-8), edit, and save. No proprietary state.
//
//  M1.1: autosave. Edits are flushed after a short idle, when the app loses focus or
//  quits, and before switching to another file — every write is byte-exact and atomic
//  (via MarkdownFileIO). `loadedText` is the on-disk truth; `text` diverging from it is
//  the dirty signal. (The proper structural home for this is the L2 DocumentModel —
//  architecture §2.2 — which also removes the whole-string SwiftUI binding; M1.1.)
//

import AppKit
import Combine
import SwiftUI

@MainActor
final class LibraryModel: ObservableObject {
    @Published var folderURL: URL?
    @Published var files: [URL] = []
    @Published var text: String = ""
    @Published var selectedFile: URL? {
        didSet {
            guard selectedFile != oldValue else { return }
            // Flush unsaved edits of the file we're leaving before switching away.
            if let previous = oldValue, text != loadedText {
                try? MarkdownFileIO.write(text, to: previous)
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

    private var accessedFolder: URL?
    /// The file's on-disk content — what the editor last loaded or saved. `text != loadedText`
    /// means there are unsaved edits.
    private var loadedText = ""
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

    // MARK: - Folder

    func openFolder() {
        let panel = NSOpenPanel()
        panel.canChooseDirectories = true
        panel.canChooseFiles = false
        panel.allowsMultipleSelection = false
        panel.canCreateDirectories = true
        panel.prompt = String(localized: "Open")
        panel.message = String(localized: "Choose a folder of Markdown files.")
        guard panel.runModal() == .OK, let url = panel.url else { return }

        // Session-scoped access to the chosen folder (and its descendants).
        accessedFolder?.stopAccessingSecurityScopedResource()
        _ = url.startAccessingSecurityScopedResource()
        accessedFolder = url

        folderURL = url
        selectedFile = nil
        text = ""
        loadedText = ""
        refreshFiles()
    }

    func refreshFiles() {
        guard let folderURL else {
            files = []
            return
        }
        let contents =
            (try? FileManager.default.contentsOfDirectory(
                at: folderURL,
                includingPropertiesForKeys: [.isRegularFileKey],
                options: [.skipsHiddenFiles])) ?? []
        files =
            contents
            .filter { url in
                ["md", "markdown", "mdc"].contains(url.pathExtension.lowercased())
                    || AgentFileRecognizer.kind(for: url) != nil
            }
            .sorted {
                $0.lastPathComponent.localizedCaseInsensitiveCompare($1.lastPathComponent)
                    == .orderedAscending
            }
    }

    // MARK: - File

    private func loadSelected() {
        defer { isSwitching = false }
        guard let url = selectedFile else {
            text = ""
            loadedText = ""
            return
        }
        do {
            let contents = try MarkdownFileIO.read(url)
            text = contents
            loadedText = contents
        } catch MarkdownFileIO.IOError.notValidUTF8 {
            text = ""
            loadedText = ""
            report(
                String(
                    localized:
                        "\"\(url.lastPathComponent)\" isn't valid UTF-8. Colophon won't open it to avoid corrupting the file."
                )
            )
        } catch {
            text = ""
            loadedText = ""
            report(
                String(
                    localized:
                        "Couldn't open \"\(url.lastPathComponent)\": \(error.localizedDescription)"
                )
            )
        }
    }

    func save() {
        guard let url = selectedFile else { return }
        do {
            try MarkdownFileIO.write(text, to: url)
            loadedText = text
        } catch {
            report(
                String(
                    localized:
                        "Couldn't save \"\(url.lastPathComponent)\": \(error.localizedDescription)"
                )
            )
        }
    }

    /// Save on idle / focus loss / quit. Silent on failure (retries on the next edit);
    /// explicit `save()` surfaces the error. Skipped mid-switch so a stale `text` is never
    /// written to the newly selected file.
    private func autosaveIfNeeded() {
        guard !isSwitching, let url = selectedFile, text != loadedText else { return }
        do {
            try MarkdownFileIO.write(text, to: url)
            loadedText = text
        } catch {
            // Intentionally silent — see doc comment.
        }
    }

    // MARK: - Helpers

    private func report(_ message: String) {
        NSSound.beep()
        let alert = NSAlert()
        alert.messageText = message
        alert.addButton(withTitle: String(localized: "OK"))
        alert.runModal()
    }
}
