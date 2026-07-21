// SPDX-License-Identifier: Apache-2.0
//
//  ContentView.swift
//  Colophon
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var model: LibraryModel

    var body: some View {
        NavigationSplitView {
            // Sidebar — the library
            List {
                Button {
                    model.openFolder()
                } label: {
                    Label(model.folderURL?.lastPathComponent ?? "Open Folder…",
                          systemImage: "folder")
                }
            }
            .navigationSplitViewColumnWidth(min: 180, ideal: 220)
        } content: {
            // Middle — the Markdown files in the folder
            Group {
                if model.folderURL == nil {
                    placeholder("Open a folder to begin", systemImage: "folder")
                } else if model.files.isEmpty {
                    placeholder("No .md files in this folder", systemImage: "doc.text")
                } else {
                    List(model.files, id: \.self, selection: $model.selectedFile) { url in
                        Text(url.lastPathComponent)
                    }
                }
            }
            .navigationSplitViewColumnWidth(min: 200, ideal: 280)
        } detail: {
            // Editor
            if model.selectedFile != nil {
                MarkdownTextView(text: $model.text)
                    .toolbar {
                        ToolbarItem(placement: .primaryAction) {
                            Button {
                                model.save()
                            } label: {
                                Label("Save", systemImage: "square.and.arrow.down")
                            }
                        }
                    }
            } else {
                placeholder("Select a file", systemImage: "doc.text")
            }
        }
    }

    private func placeholder(_ title: String, systemImage: String) -> some View {
        VStack(spacing: 8) {
            Image(systemName: systemImage)
                .font(.largeTitle)
                .foregroundStyle(.secondary)
            Text(title)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
