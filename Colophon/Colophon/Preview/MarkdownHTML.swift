// SPDX-License-Identifier: Apache-2.0
//
//  MarkdownHTML.swift
//  Colophon
//
//  L4 preview pipeline (Model → HTML, one way). Renders Markdown to HTML with cmark-gfm —
//  the SAME engine swift-markdown parses with, so the preview dialect matches the editor
//  (decision D-M1-5, branch ①). GFM extensions + footnotes are on; `CMARK_OPT_SOURCEPOS`
//  stamps `data-sourcepos` on every block element (the anchor map for future scroll sync).
//  Safe mode (no CMARK_OPT_UNSAFE) — raw HTML / javascript: links are stripped, the first
//  line of defense for previewing untrusted (agent-authored) Markdown (security §R1.2).
//

import Foundation
import cmark_gfm
import cmark_gfm_extensions

enum MarkdownHTML {
    /// Render Markdown source to an HTML body fragment. Returns "" on failure.
    static func render(_ source: String) -> String {
        cmark_gfm_core_extensions_ensure_registered()

        let options = CMARK_OPT_SOURCEPOS | CMARK_OPT_FOOTNOTES
        guard let parser = cmark_parser_new(options) else { return "" }
        defer { cmark_parser_free(parser) }

        // GFM extensions — match swift-markdown's dialect.
        for name in ["table", "strikethrough", "tasklist", "autolink"] {
            if let ext = cmark_find_syntax_extension(name) {
                cmark_parser_attach_syntax_extension(parser, ext)
            }
        }

        source.withCString { cmark_parser_feed(parser, $0, strlen($0)) }
        guard let document = cmark_parser_finish(parser) else { return "" }
        defer { cmark_node_free(document) }

        let extensions = cmark_parser_get_syntax_extensions(parser)
        guard let htmlC = cmark_render_html(document, options, extensions) else { return "" }
        defer { free(htmlC) }
        return String(cString: htmlC)
    }
}
