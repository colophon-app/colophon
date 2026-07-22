// SPDX-License-Identifier: Apache-2.0
//
//  TextBufferTests.swift
//  ColophonTests
//
//  Locks the L2 text buffer (M1.1): load() keeps the source byte-exact (the string save()
//  writes and the dirty check compares), a file switch clears the undo stack (so Cmd-Z can't
//  replay a prior file's edit), and buffer.string drives the dirty comparison. The live
//  cross-file-undo-no-op and IME behaviours are manual gates (they need a real NSTextView) —
//  see the Round B checklist.
//

import Foundation
import Testing

@testable import Colophon

@MainActor
struct TextBufferTests {
    // The same torture set as MarkdownFileIOTests.roundTripIsByteExact: BOM, CRLF, mixed
    // endings, a missing trailing newline, CJK/emoji, and empty must all survive load()
    // unchanged in buffer.string.
    private let samples = [
        "# Title\n\nA paragraph with **bold** and a [link](x).\n",
        "no trailing newline",
        "windows\r\nline\r\nendings\r\n",
        "mixed\nline\r\nendings\n",
        "unicode: cafe \u{2014} \u{201C}curly\u{201D} \u{2014} \u{4E2D}\u{6587} \u{1F600}\n",
        "\u{FEFF}# BOM + CRLF + no trailing\r\n\r\nsecond line\r\nlast line, no newline",
        "\u{FEFF}bom then a single LF\n",
        "",
    ]

    @Test func loadIsByteExact() {
        let buffer = TextBuffer()
        for sample in samples {
            buffer.load(sample)
            #expect(buffer.string == sample)
        }
    }

    @Test func loadClearsUndo() {
        let buffer = TextBuffer()
        buffer.load("first")
        buffer.undoManager.beginUndoGrouping()
        buffer.undoManager.registerUndo(withTarget: buffer) { _ in }
        buffer.undoManager.endUndoGrouping()
        #expect(buffer.undoManager.canUndo)
        buffer.load("second")  // a file switch is not undoable
        #expect(!buffer.undoManager.canUndo)
    }

    @Test func stringDrivesTheDirtyComparison() {
        let buffer = TextBuffer()
        buffer.load("hello")
        let document = Document(url: URL(fileURLWithPath: "/tmp/x.md"), onDiskText: "hello")
        #expect(buffer.string == document.onDiskText)  // clean right after load
        buffer.load("hello world")
        #expect(buffer.string != document.onDiskText)  // now differs → dirty
    }
}
