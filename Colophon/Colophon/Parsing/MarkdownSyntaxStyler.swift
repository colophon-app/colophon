// SPDX-License-Identifier: Apache-2.0
//
//  MarkdownSyntaxStyler.swift
//  Colophon
//
//  M1.0 spike (decisions D-M1-1/D-M1-2): "source styling", NOT hybrid rendering.
//  Parses the source with swift-markdown (the full-AST track, architecture §4.2) and
//  produces display-attribute runs: headings larger, strong bold, emphasis slanted,
//  code monospaced + a subtle wash, and the leading `#` markers de-emphasised but
//  PRESENT. It never mutates the source string (byte-exact stays intact — the view
//  applies these as attributes only) and never touches `.layoutManager`.
//
//  This is a pure function (String in → runs out), so it is safe to run off the main
//  thread. Marker-range derivation here is deliberately minimal (leading ATX hashes);
//  the general "delimiter offsets from node boundaries" helper for */_/`/~~ is an
//  M1.0.5 deliverable and is intentionally out of scope for this first slice.
//

import AppKit
import Markdown

/// One run of display attributes over a UTF-16 `NSRange` of the source string.
struct StyleRun {
    let range: NSRange
    let attributes: [NSAttributedString.Key: Any]
}

enum MarkdownSyntaxStyler {
    /// Compute display-attribute runs for `source`. Order matters: callers apply the
    /// base attributes first, then these runs in array order (later runs layer on top).
    static func styleRuns(for source: String, baseFontSize: CGFloat = 14) -> [StyleRun] {
        let mapper = SourceRangeMapper(source: source)
        let document = Document(parsing: source)
        var walker = StyleWalker(source: source, mapper: mapper, baseFontSize: baseFontSize)
        walker.visit(document)
        return walker.runs
    }
}

private struct StyleWalker: MarkupWalker {
    let source: String
    let mapper: SourceRangeMapper
    let baseFontSize: CGFloat
    var runs: [StyleRun] = []

    private var monoBase: NSFont { .monospacedSystemFont(ofSize: baseFontSize, weight: .regular) }

    // MARK: Block

    mutating func visitHeading(_ heading: Heading) {
        if let ns = mapper.nsRange(heading.range) {
            let size = baseFontSize * headingScale(heading.level)
            runs.append(
                StyleRun(
                    range: ns,
                    attributes: [.font: NSFont.monospacedSystemFont(ofSize: size, weight: .bold)]))
            // De-emphasise the leading "###" + one space, keeping them visible.
            if let markerNS = leadingHashRange(startingAt: ns.location) {
                runs.append(
                    StyleRun(range: markerNS, attributes: [.foregroundColor: markerColor]))
            }
        }
        descendInto(heading)
    }

    mutating func visitCodeBlock(_ codeBlock: CodeBlock) {
        if let ns = mapper.nsRange(codeBlock.range) {
            runs.append(
                StyleRun(
                    range: ns,
                    attributes: [.font: monoBase, .backgroundColor: codeWashColor]))
        }
        // CodeBlock has no children to descend into.
    }

    // MARK: Inline

    mutating func visitStrong(_ strong: Strong) {
        if let ns = mapper.nsRange(strong.range) {
            runs.append(
                StyleRun(
                    range: ns,
                    attributes: [
                        .font: NSFont.monospacedSystemFont(ofSize: baseFontSize, weight: .bold)
                    ]))
        }
        descendInto(strong)
    }

    mutating func visitEmphasis(_ emphasis: Emphasis) {
        if let ns = mapper.nsRange(emphasis.range) {
            // Oblique the monospaced glyphs (no dedicated mono-italic on the system font).
            runs.append(StyleRun(range: ns, attributes: [.obliqueness: 0.18]))
        }
        descendInto(emphasis)
    }

    mutating func visitInlineCode(_ inlineCode: InlineCode) {
        if let ns = mapper.nsRange(inlineCode.range) {
            runs.append(
                StyleRun(
                    range: ns,
                    attributes: [.font: monoBase, .backgroundColor: codeWashColor]))
        }
    }

    // MARK: Helpers

    private func headingScale(_ level: Int) -> CGFloat {
        switch level {
        case 1: return 1.9
        case 2: return 1.6
        case 3: return 1.35
        case 4: return 1.2
        case 5: return 1.1
        default: return 1.0
        }
    }

    /// From a heading's UTF-16 start offset, span the leading run of `#` plus one
    /// trailing space (ATX heading marker). Returns nil for setext headings (no `#`).
    private func leadingHashRange(startingAt start: Int) -> NSRange? {
        let ns = source as NSString
        var end = start
        while end < ns.length, ns.character(at: end) == UInt16(UnicodeScalar("#").value) {
            end += 1
        }
        guard end > start else { return nil }  // not an ATX heading
        if end < ns.length, ns.character(at: end) == UInt16(UnicodeScalar(" ").value) {
            end += 1
        }
        return NSRange(location: start, length: end - start)
    }

    private var markerColor: NSColor { .tertiaryLabelColor }
    private var codeWashColor: NSColor { NSColor.secondaryLabelColor.withAlphaComponent(0.08) }
}
