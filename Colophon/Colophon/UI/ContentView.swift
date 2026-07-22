// SPDX-License-Identifier: Apache-2.0
//
//  ContentView.swift
//  Colophon
//

import SwiftUI
import UniformTypeIdentifiers

struct ContentView: View {
    @EnvironmentObject private var model: LibraryModel
    @State private var isChoosingFolder = false

    var body: some View {
        NavigationSplitView {
            // Sidebar — the library
            List {
                Button {
                    isChoosingFolder = true
                } label: {
                    if let name = model.folderURL?.lastPathComponent {
                        // A folder name is content, not UI copy — never localize it.
                        Label {
                            Text(verbatim: name)
                        } icon: {
                            Image(systemName: "folder")
                        }
                    } else {
                        Label("Open Folder…", systemImage: "folder")
                    }
                }
            }
            .navigationSplitViewColumnWidth(min: 180, ideal: 220)
        } content: {
            // Middle — the folder's Markdown / agent files as an expandable tree
            Group {
                if model.folderURL == nil {
                    placeholder("Open a folder to begin", systemImage: "folder")
                } else if model.fileTree.isEmpty {
                    placeholder("No Markdown files in this folder", systemImage: "doc.text")
                } else {
                    List(model.fileTree, children: \.children, selection: $model.selectedFile) {
                        node in
                        fileRow(node)
                            .selectionDisabled(node.isDirectory)
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
        .fileImporter(isPresented: $isChoosingFolder, allowedContentTypes: [.folder]) { result in
            if case .success(let url) = result {
                model.openFolder(url)
            }
        }
        .alert(model.lastError ?? "", isPresented: errorAlertBinding) {
            Button("OK", role: .cancel) {}
        }
        // Window title tracks the open document (verbatim — a filename is content, not copy).
        .navigationTitle(Text(verbatim: model.document?.displayName ?? "Colophon"))
    }

    /// Bridges the model's `lastError` to an alert; clearing on dismiss keeps presentation
    /// in the view, not the model.
    private var errorAlertBinding: Binding<Bool> {
        Binding(get: { model.lastError != nil }, set: { if !$0 { model.lastError = nil } })
    }

    @ViewBuilder
    private func fileRow(_ node: FileNode) -> some View {
        if node.isDirectory {
            Label {
                Text(verbatim: node.name)
            } icon: {
                Image(systemName: "folder").foregroundStyle(.secondary)
            }
        } else {
            let kind = node.agentKind
            Label {
                Text(verbatim: node.name)
            } icon: {
                Image(systemName: kind?.symbolName ?? "doc.text")
                    .foregroundStyle(kind == nil ? AnyShapeStyle(.secondary) : AnyShapeStyle(.tint))
            }
        }
    }

    private func placeholder(_ title: LocalizedStringKey, systemImage: String) -> some View {
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
