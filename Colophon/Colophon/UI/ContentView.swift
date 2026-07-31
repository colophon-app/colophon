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
    @State private var showPreview = false
    @State private var previewSync = PreviewSync()

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
            // Editor + optional split preview
            if model.selectedFile != nil {
                VStack(spacing: 0) {
                    // Non-modal banner when the open file changed on disk (M1.2) — editing
                    // continues underneath; nothing is written until the user chooses.
                    if let pending = model.pendingExternalChange {
                        ExternalChangeBanner(
                            fileName: pending.url.lastPathComponent,
                            onReload: { model.reloadFromPending() },
                            onIgnore: { model.ignorePending() })
                    }
                    HSplitView {
                        MarkdownTextView(buffer: model.buffer, sync: previewSync)
                            .frame(minWidth: 320)
                        if showPreview {
                            PreviewWebView(buffer: model.buffer, sync: previewSync)
                                .frame(minWidth: 320)
                        }
                    }
                }
                .toolbar {
                    ToolbarItem {
                        Button {
                            showPreview.toggle()
                        } label: {
                            Label("Preview", systemImage: "sidebar.right")
                        }
                        .keyboardShortcut("\\", modifiers: .command)
                    }
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

/// Non-modal banner shown when the open file changed on disk under the user (M1.2). Editing
/// continues underneath; Reload takes the disk version (undoable), Keep Mine keeps the edits.
private struct ExternalChangeBanner: View {
    let fileName: String
    let onReload: () -> Void
    let onIgnore: () -> Void

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundStyle(.orange)
            // A filename is content, not UI copy — never localize it.
            Text(verbatim: fileName).fontWeight(.semibold)
            Text("changed on disk").foregroundStyle(.secondary)
            Spacer()
            Button("Reload", action: onReload)
            Button("Keep Mine", action: onIgnore)
        }
        .font(.callout)
        .padding(.horizontal, 14)
        .padding(.vertical, 8)
        .background(.regularMaterial)
        .overlay(alignment: .bottom) { Divider() }
    }
}
