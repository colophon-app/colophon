// SPDX-License-Identifier: Apache-2.0
//
//  FileTree.swift
//  Colophon
//
//  L2: the library's file tree. A `FileNode` is a folder (with children) or a Markdown /
//  agent file. The builder recurses the chosen folder, keeping only Markdown-family and
//  recognized agent files, plus the folders that (transitively) contain them — so noise
//  like `.git` or a source tree with no docs never shows.
//
//  NOTE (architecture §2.3): this builds the whole tree eagerly. Fine for typical vaults;
//  lazy enumeration for 10k+ files is a later refinement.
//

import Foundation

struct FileNode: Identifiable {
    let url: URL
    let isDirectory: Bool
    /// Child nodes for a folder; nil for a file (so the outline shows no disclosure).
    var children: [FileNode]?

    var id: URL { url }
    var name: String { url.lastPathComponent }
    var agentKind: AgentFileKind? { isDirectory ? nil : AgentFileRecognizer.kind(for: url) }
}

enum FileTreeBuilder {
    static func build(root: URL) -> [FileNode] {
        children(of: root)
    }

    private static func children(of directory: URL) -> [FileNode] {
        let contents =
            (try? FileManager.default.contentsOfDirectory(
                at: directory,
                includingPropertiesForKeys: [.isDirectoryKey],
                options: [.skipsHiddenFiles])) ?? []

        var nodes: [FileNode] = []
        for url in contents {
            let isDirectory =
                (try? url.resourceValues(forKeys: [.isDirectoryKey]).isDirectory) ?? false
            if isDirectory {
                let sub = children(of: url)
                if !sub.isEmpty {  // keep only folders that contain Markdown/agent files
                    nodes.append(FileNode(url: url, isDirectory: true, children: sub))
                }
            } else if isMarkdownLike(url) {
                nodes.append(FileNode(url: url, isDirectory: false, children: nil))
            }
        }
        // Folders first, then files; alphabetical within each.
        return nodes.sorted { a, b in
            if a.isDirectory != b.isDirectory { return a.isDirectory }
            return a.name.localizedCaseInsensitiveCompare(b.name) == .orderedAscending
        }
    }

    private static func isMarkdownLike(_ url: URL) -> Bool {
        ["md", "markdown", "mdc"].contains(url.pathExtension.lowercased())
            || AgentFileRecognizer.kind(for: url) != nil
    }
}
