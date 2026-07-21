// SPDX-License-Identifier: Apache-2.0
//
//  LibraryModel.swift
//  Colophon
//
//  M0 skeleton: a folder is the library. Open a folder, list its Markdown files,
//  load one (strict UTF-8), edit, and save atomically. No proprietary state.
//

import SwiftUI
import AppKit
import Combine

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
        panel.prompt = "Open"
        panel.message = "Choose a folder of Markdown files."
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
        let contents = (try? FileManager.default.contentsOfDirectory(
            at: folderURL,
            includingPropertiesForKeys: [.isRegularFileKey],
            options: [.skipsHiddenFiles])) ?? []
        files = contents
            .filter { ["md", "markdown"].contains($0.pathExtension.lowercased()) }
            .sorted {
                $0.lastPathComponent.localizedCaseInsensitiveCompare($1.lastPathComponent) == .orderedAscending
            }
    }

    // MARK: - File

    private func loadSelected() {
        guard let url = selectedFile else {
            text = ""
            return
        }
        do {
            let data = try Data(contentsOf: url)
            // Strict UTF-8: refuse rather than lossy-decode and corrupt the file.
            guard let string = String(data: data, encoding: .utf8) else {
                text = ""
                report("\"\(url.lastPathComponent)\" isn't valid UTF-8. Colophon won't open it to avoid corrupting the file.")
                return
            }
            text = string
        } catch {
            text = ""
            report("Couldn't open \"\(url.lastPathComponent)\": \(error.localizedDescription)")
        }
    }

    func save() {
        guard let url = selectedFile else { return }
        guard let data = text.data(using: .utf8) else {
            report("Couldn't encode the document as UTF-8.")
            return
        }
        do {
            // Atomic write (write-to-temp then rename). Final I/O API (metadata
            // preservation / file coordination) is decided in M1.
            try data.write(to: url, options: [.atomic])
        } catch {
            report("Couldn't save \"\(url.lastPathComponent)\": \(error.localizedDescription)")
        }
    }

    // MARK: - Helpers

    private func report(_ message: String) {
        NSSound.beep()
        let alert = NSAlert()
        alert.messageText = message
        alert.addButton(withTitle: "OK")
        alert.runModal()
    }
}
