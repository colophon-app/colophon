// SPDX-License-Identifier: Apache-2.0
//
//  SourceRangeMapper.swift
//  Colophon
//
//  Maps swift-markdown `SourceRange` (1-based line + 1-based, UTF-8-byte column)
//  onto `NSRange` (UTF-16) for a given source string.
//
//  Why this exists (M1 research §D1/§D2 risk, decisions D-M1-1): swift-markdown
//  reports locations as line/column measured in UTF-8 bytes, while NSTextView /
//  NSRange are UTF-16. A naïve conversion is off-by-one on CJK / emoji / combining
//  sequences — and a wrong offset that ever feeds an *edit* is a byte-exact
//  correctness bug. All AST→NSRange conversion goes through this one utility so the
//  hazard is tested in exactly one place (see MarkdownStylingTests).
//
//  NOTE (M1.0 spike assumption to confirm): we assume `column` counts UTF-8 bytes
//  within the line. The CJK/emoji unit tests validate this; if swift-markdown turns
//  out to count Unicode scalars instead, only `stringIndex(line:column:)` changes.
//

import Foundation
import Markdown

struct SourceRangeMapper {
    private let source: String
    /// `String.Index` at the start of each line (line 1 at index 0). Line breaks are
    /// counted by raw `\n` (UTF-8), matching swift-markdown — NOT by `Character`,
    /// because Swift treats `\r\n` as a single grapheme and would miscount CRLF files.
    private let lineStarts: [String.Index]

    init(source: String) {
        self.source = source
        var starts: [String.Index] = [source.startIndex]
        let utf8 = source.utf8
        var i = utf8.startIndex
        while i != utf8.endIndex {
            let next = utf8.index(after: i)
            if utf8[i] == 0x0A {  // '\n'
                starts.append(next)
            }
            i = next
        }
        self.lineStarts = starts
    }

    /// A `String.Index` for a 1-based line and 1-based UTF-8-byte column, or nil if
    /// out of range. Advances only *within* the line, so it is O(line length).
    func stringIndex(line: Int, column: Int) -> String.Index? {
        guard line >= 1, line <= lineStarts.count, column >= 1 else { return nil }
        let base = lineStarts[line - 1]
        return source.utf8.index(base, offsetBy: column - 1, limitedBy: source.utf8.endIndex)
    }

    /// Convert a `SourceRange` to an `NSRange` (UTF-16) in the source string.
    /// `NSRange(_:in:)` does the UTF-16 arithmetic correctly for any valid index range.
    func nsRange(_ range: SourceRange?) -> NSRange? {
        guard let range,
            let lo = stringIndex(line: range.lowerBound.line, column: range.lowerBound.column),
            let hi = stringIndex(line: range.upperBound.line, column: range.upperBound.column),
            lo <= hi
        else { return nil }
        return NSRange(lo..<hi, in: source)
    }
}
