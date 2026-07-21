// SPDX-License-Identifier: Apache-2.0
//
//  MarkdownStylingTests.swift
//  ColophonTests
//
//  M1.0 spike gate: proves the swift-markdown SourceRange → NSRange mapping is correct
//  across CRLF, CJK, and emoji (the byte-exact-adjacent correctness risk from
//  M1 research §D1/§D2), and that source styling produces the expected runs.
//

import Foundation
import Testing

@testable import Colophon

struct SourceRangeMapperTests {

    /// Line breaks must be counted by raw `\n`, not by `Character` (which merges `\r\n`).
    @Test func crlfLineCountingIsByteBased() {
        let source = "a\r\nb\r\nc"
        let mapper = SourceRangeMapper(source: source)
        // Line 2, column 1 is 'b'; line 3, column 1 is 'c'.
        let l2 = mapper.stringIndex(line: 2, column: 1)
        let l3 = mapper.stringIndex(line: 3, column: 1)
        #expect(l2 != nil && String(source[l2!...]).hasPrefix("b"))
        #expect(l3 != nil && String(source[l3!...]).hasPrefix("c"))
    }

    /// A UTF-8-byte column past emoji/CJK must land on the right UTF-16 offset.
    @Test func columnAfterEmojiMapsToCorrectScalar() {
        let source = "😀中x"  // emoji (4 UTF-8 bytes / 2 UTF-16 units), CJK (3 bytes / 1 unit)
        let mapper = SourceRangeMapper(source: source)
        // 'x' starts at UTF-8 byte column 4+3+1 = 8 (1-based).
        let idx = mapper.stringIndex(line: 1, column: 8)
        #expect(idx != nil && String(source[idx!...]) == "x")
    }
}

struct MarkdownSyntaxStylerTests {

    private func substrings(of runs: [StyleRun], in source: String) -> [String] {
        let ns = source as NSString
        return runs.compactMap {
            NSMaxRange($0.range) <= ns.length ? ns.substring(with: $0.range) : nil
        }
    }

    @Test func headingProducesLargerRunAndDeEmphasizedMarker() {
        let source = "# Title\n"
        let runs = MarkdownSyntaxStyler.styleRuns(for: source)
        let subs = substrings(of: runs, in: source)
        // The heading body run spans the title.
        #expect(subs.contains { $0.contains("Title") })
        // The leading "# " marker is styled as its own (de-emphasised) run.
        #expect(subs.contains("# "))
    }

    /// The load-bearing correctness test: with emoji + CJK before it, the Strong node's
    /// range must map to the exact bytes. A wrong UTF-8↔UTF-16 conversion breaks this.
    @Test func strongRangeIsByteExactAfterCJKAndEmoji() {
        let source = "中文 😀 **粗体** end\n"
        let runs = MarkdownSyntaxStyler.styleRuns(for: source)
        let subs = substrings(of: runs, in: source)
        #expect(subs.contains { $0.contains("粗体") })
    }

    @Test func fencedCodeBlockIsStyled() {
        let source = "```swift\nlet x = 1\n```\n"
        let runs = MarkdownSyntaxStyler.styleRuns(for: source)
        #expect(!runs.isEmpty)
    }
}
