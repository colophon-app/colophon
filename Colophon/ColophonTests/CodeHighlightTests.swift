// SPDX-License-Identifier: Apache-2.0
//
//  CodeHighlightTests.swift
//  ColophonTests
//
//  Locks the server-side highlighter (D-M1-14): that hljs actually runs, that the
//  <pre data-sourcepos> scroll anchor is never touched, and that every fallback path
//  (unknown language, no info string, oversized fence) leaves the block plain. A
//  swift-cmark or highlight.js bump that changes the HTML shape fails here instead of
//  silently mis-rendering.
//

import Foundation
import Testing

@testable import Colophon

struct CodeHighlightTests {
    /// The `<pre …>` opening tag cmark emitted, verbatim (up to and including the '>').
    private func preOpeningTag(_ html: String) -> String? {
        guard let start = html.range(of: "<pre"),
            let close = html.range(of: ">", range: start.lowerBound..<html.endIndex)
        else { return nil }
        return String(html[start.lowerBound...close.lowerBound])
    }

    @Test func swiftFenceGetsHljsSpans() {
        let html = MarkdownHTML.renderHighlighted("```swift\nlet x = 1\n```\n")
        // `let` is a Swift keyword → proves hljs ran and the current class set is present.
        #expect(html.contains("class=\"hljs-keyword\""))
    }

    @Test func preDataSourceposIsPreservedByteForByte() throws {
        let source = "```swift\nlet x = 1\n```\n"
        let plainPre = try #require(preOpeningTag(MarkdownHTML.render(source)))
        // The load-bearing scroll-sync invariant: only the inside of <code> is rewritten.
        #expect(plainPre.contains("data-sourcepos="))
        #expect(MarkdownHTML.renderHighlighted(source).contains(plainPre))
    }

    @Test func unknownLanguageStaysPlain() {
        let html = MarkdownHTML.renderHighlighted("```qwerty\nlet x = 1\n```\n")
        #expect(!html.contains("hljs"))  // no token spans, no `hljs` container class
        #expect(html.contains("language-qwerty"))  // cmark's class preserved untouched
    }

    @Test func fenceWithoutLanguageIsUntouched() {
        let source = "```\nplain text\n```\n"
        // No `language-` class → the regex never matches → output is identical to plain render.
        #expect(MarkdownHTML.renderHighlighted(source) == MarkdownHTML.render(source))
    }

    @Test func oversizedFenceStaysPlain() {
        let body = String(repeating: "let x = 1\n", count: 6000)  // ~60 KB, over the 40 KB cap
        let html = MarkdownHTML.renderHighlighted("```swift\n\(body)```\n")
        #expect(!html.contains("hljs"))  // highlighting skipped → block left plain
    }

    @Test func literalEntityInCodeIsNotCorrupted() {
        // Source text is the literal `&lt;`; cmark emits `&amp;lt;`. Correct unescape order
        // (&amp; last) feeds hljs the literal `&lt;`, which it re-escapes back to `&amp;lt;`.
        // Wrong order would leak a bare `<` and corrupt the markup.
        let html = MarkdownHTML.renderHighlighted("```swift\nlet s = \"&lt;\"\n```\n")
        #expect(html.contains("&amp;lt;"))
    }
}
