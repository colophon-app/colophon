// SPDX-License-Identifier: Apache-2.0
//
//  LibraryModel.swift
//  Colophon
//
//  M0 skeleton: a folder is the library. Open a folder, list its Markdown files,
//  load one (strict UTF-8), edit, and save atomically. No proprietary state.
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
            loadSelected()
        }
    }

    private var accessedFolder: URL?

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
            .filter { ["md", "markdown"].contains($0.pathExtension.lowercased()) }
            .sorted {
                $0.lastPathComponent.localizedCaseInsensitiveCompare($1.lastPathComponent)
                    == .orderedAscending
            }
    }

    // MARK: - File

    private func loadSelected() {
        guard let url = selectedFile else {
            text = ""
            return
        }
        do {
            text = try MarkdownFileIO.read(url)
        } catch MarkdownFileIO.IOError.notValidUTF8 {
            text = ""
            report(
                String(
                    localized:
                        "\"\(url.lastPathComponent)\" isn't valid UTF-8. Colophon won't open it to avoid corrupting the file."
                )
            )
        } catch {
            text = ""
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
        } catch {
            report(
                String(
                    localized:
                        "Couldn't save \"\(url.lastPathComponent)\": \(error.localizedDescription)"
                )
            )
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
