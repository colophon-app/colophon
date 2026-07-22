// SPDX-License-Identifier: Apache-2.0
//
//  Document.swift
//  Colophon
//
//  L2: the context of one open file. The editable buffer lives in `LibraryModel.text` (the
//  editor binds to it directly); this value captures the open file's identity, its on-disk
//  snapshot (for the dirty check), and derived facts. Separating "the open document" from
//  "the library" (folder + file list) is architecture §2.2's Library/Document boundary.
//
//  Byte-exact fidelity note: BOM, line endings, and trailing newline are preserved because
//  the source text is never normalized — they live IN the string (a leading U+FEFF, the
//  actual CR/LF bytes). So no separate fidelity fields are needed today; if a future feature
//  ever normalizes the buffer for display, record them here (architecture §3.2).
//

import Foundation

struct Document: Equatable {
    let url: URL
    /// The file's content as last loaded or saved. The dirty check compares the live buffer
    /// against this snapshot.
    let onDiskText: String

    var displayName: String { url.lastPathComponent }
    var agentKind: AgentFileKind? { AgentFileRecognizer.kind(for: url) }
}
