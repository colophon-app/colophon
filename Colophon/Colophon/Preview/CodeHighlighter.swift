// SPDX-License-Identifier: Apache-2.0
//
//  CodeHighlighter.swift
//  Colophon
//
//  L4 preview: server-side syntax highlighting for fenced code blocks (decision D-M1-14).
//  highlight.js runs in an in-process JavaScriptCore context inside the render pipeline —
//  it NEVER executes in the WKWebView. cmark emits `<pre data-sourcepos><code
//  class="language-XXX">ESCAPED</code></pre>`; we rewrite ONLY the inside of each <code>
//  into hljs token <span>s and leave the <pre> (and its data-sourcepos anchor) byte-
//  identical, so the caret-follow scroll map (M1.4.b) stays correct. The webview receives
//  only pre-tokenized markup — zero new script, so the preview CSP is unchanged and
//  connect-src 'none' (zero outbound) is preserved.
//
//  Threading (load-bearing): JavaScriptCore is not thread-safe across queues. The JSContext
//  is created exactly once, reused, and touched ONLY from one private serial queue. All hljs
//  calls run on that queue, off the main thread; the caller hops back to main just for
//  loadHTMLString. `applyHighlighting(to:)` wraps the work in `queue.sync`, so callers MUST
//  NOT already be on `queue` (they aren't — the live path dispatches from a global queue,
//  tests call from the test thread).
//
//  Three JSCore/hljs traps handled here (surfaced by the M1.4.c design review):
//   1. hljs.highlight() THROWS on an unregistered language (ignoreIllegals does NOT suppress
//      that) — we guard with hljs.getLanguage() and wrap the call in a JS try/catch that
//      returns null, so unknown languages fall back to plain (uncolored) code.
//   2. highlight.min.js is a UMD bundle; in a bare JSContext `window`/`self` are undefined.
//      We predefine them (pointing at the global object) before evaluating, and warm()
//      asserts `hljs` actually attached — so a bad build fails loudly, never silently.
//   3. Unbounded per-fence cost: fences larger than `maxFenceBytes` skip highlighting
//      (plain fallback) so pasting a huge/minified block can't jank the editor.
//

import Foundation
import JavaScriptCore

/// Highlights fenced code blocks in cmark's HTML output using highlight.js under
/// JavaScriptCore. A process-wide singleton owning one reused JSContext on one serial queue.
final class CodeHighlighter {
    static let shared = CodeHighlighter()

    /// The one queue allowed to touch `context`. Serial → hljs calls never overlap.
    private let queue = DispatchQueue(label: "app.colophon.code-highlighter")
    private var context: JSContext?
    private var highlightFn: JSValue?
    private var isReady = false

    /// Fences whose (unescaped) body exceeds this are left plain — highlighting a huge or
    /// minified block would block the queue and, transitively, the debounced render.
    private let maxFenceBytes = 40_000

    // cmark's deterministic fenced-code output: `<pre ATTRS><code class="language-LANG">BODY
    // </code></pre>`. ATTRS holds data-sourcepos (no '>' inside); BODY is HTML-escaped so the
    // first literal `</code></pre>` is always the real terminator. Blocks with no
    // `language-` class (indented / no info string) don't match and are left untouched.
    private static let fenceRegex = try! NSRegularExpression(
        pattern: "<pre([^>]*)><code class=\"language-([^\"]+)\">([\\s\\S]*?)</code></pre>")

    private init() {}

    // MARK: - Public

    /// Pre-initialize the context so the first real render doesn't pay the cold-start cost
    /// (context creation + hljs eval, tens of ms). Safe to call more than once.
    func warm() {
        queue.async { [weak self] in self?.ensureReady() }
    }

    /// Rewrite each `language-`-classed fenced code block in `html` with hljs token spans.
    /// Synchronous; hops onto the private JS queue internally, so DO NOT call from that queue.
    /// Unknown-language, oversized, and failed blocks are returned untouched.
    func applyHighlighting(to html: String) -> String {
        queue.sync {
            ensureReady()
            guard isReady else { return html }
            return rewriteFences(in: html)
        }
    }

    // MARK: - Context (queue-only)

    /// Create + load hljs once. MUST run on `queue`.
    private func ensureReady() {
        guard context == nil else { return }
        guard let context = JSContext() else { return }
        self.context = context

        // Any JS exception during load/highlight lands here (and is cleared). We also
        // try/catch inside the helper, so this is a backstop, not the common path.
        context.exceptionHandler = { _, exception in
            NSLog("[CodeHighlighter] JS exception: %@", exception?.toString() ?? "unknown")
        }

        guard
            let url = Bundle(for: CodeHighlighter.self)
                .url(forResource: "highlight.min", withExtension: "js"),
            let source = try? String(contentsOf: url, encoding: .utf8)
        else {
            NSLog("[CodeHighlighter] highlight.min.js not found in bundle — code stays plain.")
            return
        }

        // UMD shim: point window/self at the global object so hljs attaches there. Then a
        // guarded helper that does the getLanguage() check + try/catch entirely in JS, so
        // unknown languages return null instead of throwing.
        let bootstrap = """
            var window = this; var self = this;
            \(source)
            var __colophonHighlight = function (code, language) {
              try {
                if (!language || typeof hljs === 'undefined' || !hljs.getLanguage(language)) {
                  return null;
                }
                return hljs.highlight(code, { language: language, ignoreIllegals: true }).value;
              } catch (e) {
                return null;
              }
            };
            """
        context.evaluateScript(bootstrap)

        guard let hljs = context.objectForKeyedSubscript("hljs"),
            !hljs.isUndefined, !hljs.isNull
        else {
            // The vendored build did not attach its global — fail loudly in debug, degrade
            // to plain code in release rather than silently mis-render.
            assertionFailure("[CodeHighlighter] hljs global did not attach after eval.")
            NSLog("[CodeHighlighter] hljs global missing — code stays plain.")
            return
        }
        highlightFn = context.objectForKeyedSubscript("__colophonHighlight")
        isReady = highlightFn?.isUndefined == false
    }

    // MARK: - Rewrite (queue-only)

    private func rewriteFences(in html: String) -> String {
        let ns = html as NSString
        let matches = Self.fenceRegex.matches(
            in: html, range: NSRange(location: 0, length: ns.length))
        guard !matches.isEmpty else { return html }

        var out = ""
        var cursor = 0
        for match in matches {
            let whole = match.range
            out += ns.substring(with: NSRange(location: cursor, length: whole.location - cursor))
            cursor = whole.location + whole.length

            let attrs = ns.substring(with: match.range(at: 1))
            let language = ns.substring(with: match.range(at: 2))
            let escapedBody = ns.substring(with: match.range(at: 3))

            if let highlighted = highlight(escapedBody: escapedBody, language: language) {
                out += "<pre\(attrs)><code class=\"language-\(language) hljs\">"
                out += highlighted
                out += "</code></pre>"
            } else {
                // Unknown language / oversized / failure → keep cmark's original block verbatim.
                out += ns.substring(with: whole)
            }
        }
        out += ns.substring(from: cursor)
        return out
    }

    /// Returns hljs-highlighted HTML for one fence, or nil to leave it plain. MUST run on `queue`.
    private func highlight(escapedBody: String, language: String) -> String? {
        let source = unescapeCmark(escapedBody)
        guard source.utf8.count <= maxFenceBytes else { return nil }
        guard let result = highlightFn?.call(withArguments: [source, language]),
            !result.isNull, !result.isUndefined
        else { return nil }
        return result.toString()
    }

    /// Reverse cmark's code escaping. cmark escapes only & < > " in code — NOT single quotes.
    /// `&amp;` MUST be undone LAST, else a literal `&lt;` in the source (emitted as `&amp;lt;`)
    /// would be corrupted into `<`.
    private func unescapeCmark(_ s: String) -> String {
        var r = s
        r = r.replacingOccurrences(of: "&lt;", with: "<")
        r = r.replacingOccurrences(of: "&gt;", with: ">")
        r = r.replacingOccurrences(of: "&quot;", with: "\"")
        r = r.replacingOccurrences(of: "&amp;", with: "&")
        return r
    }
}
