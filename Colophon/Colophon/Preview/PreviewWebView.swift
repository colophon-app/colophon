// SPDX-License-Identifier: Apache-2.0
//
//  PreviewWebView.swift
//  Colophon
//
//  L4: the split-preview pane. A WKWebView renders the cmark HTML (MarkdownHTML) inside a
//  minimal document with a strict CSP. M1.4.a rendering + M1.4.b editor→preview follow: a
//  small bundled script scrolls to a `data-sourcepos` anchor when PreviewSync reports the
//  caret line. No KaTeX/Mermaid/highlight yet (M1.4.c).
//
//  Sandbox + privacy (decision D-M1-13): a sandboxed app using WKWebView needs the
//  `com.apple.security.network.client` entitlement, but the preview makes ZERO outbound
//  requests: CSP `connect-src 'none'`, only local content, and the only script is our own
//  inline one (cmark safe-mode strips any script in the user's Markdown, so `script-src
//  'unsafe-inline'` cannot run untrusted code).
//
//  L4 contract (architecture §1.2, §4): the preview is read-only downstream of the model.
//

import Combine
import SwiftUI
import WebKit

struct PreviewWebView: NSViewRepresentable {
    let buffer: TextBuffer
    let sync: PreviewSync

    func makeCoordinator() -> Coordinator { Coordinator(sync: sync, buffer: buffer) }

    func makeNSView(context: Context) -> WKWebView {
        let configuration = WKWebViewConfiguration()
        configuration.defaultWebpagePreferences.allowsContentJavaScript = true
        configuration.websiteDataStore = .nonPersistent()

        let webView = WKWebView(frame: .zero, configuration: configuration)
        webView.navigationDelegate = context.coordinator
        // isInspectable defaults to false on macOS 13.3+; enable it in debug for Web Inspector.
        #if DEBUG
            webView.isInspectable = true
        #endif
        sync.webView = webView
        CodeHighlighter.shared.warm()  // pre-init JSCore so the first render isn't cold
        context.coordinator.start(in: webView)
        return webView
    }

    // Content changes arrive through the buffer subscription, not SwiftUI — nothing to push.
    func updateNSView(_ webView: WKWebView, context: Context) {}

    final class Coordinator: NSObject, WKNavigationDelegate {
        private let sync: PreviewSync
        private let buffer: TextBuffer
        private weak var webView: WKWebView?
        private var lastMarkdown: String?
        private var pending: DispatchWorkItem?
        private var generation = 0  // main-thread only; drops stale async highlight results
        private var cancellables = Set<AnyCancellable>()

        init(sync: PreviewSync, buffer: TextBuffer) {
            self.sync = sync
            self.buffer = buffer
        }

        /// Subscribe to the shared buffer and render its current text. A real edit (`changed`)
        /// and a file switch (`contentReloaded`) both trigger a debounced re-render that reads
        /// buffer.string once — no whole document is pushed through SwiftUI per keystroke.
        func start(in webView: WKWebView) {
            self.webView = webView
            // A file switch: start the preview at the top (not the previous file's caret line).
            buffer.contentReloaded
                .sink { [weak self] in
                    guard let self, let webView = self.webView else { return }
                    self.sync.resetToTop()
                    self.render(self.buffer.string, in: webView)
                }
                .store(in: &cancellables)
            // A normal edit: re-render and let previewDidReload follow the caret.
            buffer.changed
                .sink { [weak self] in
                    guard let self, let webView = self.webView else { return }
                    self.render(self.buffer.string, in: webView)
                }
                .store(in: &cancellables)
            render(buffer.string, in: webView)
        }

        /// Debounced re-render (the editor pushes `markdown` on every keystroke). The cmark
        /// parse + JSCore highlight pass runs OFF the main thread; only `loadHTMLString` hops
        /// back to main. A generation token drops a slow result that a newer keystroke has
        /// already superseded (highlighting is async, so results can land out of date).
        func render(_ markdown: String, in webView: WKWebView) {
            guard markdown != lastMarkdown else { return }
            lastMarkdown = markdown
            pending?.cancel()
            generation += 1
            let token = generation
            let item = DispatchWorkItem { [weak self, weak webView] in
                DispatchQueue.global(qos: .userInitiated).async {
                    let page = Self.page(body: MarkdownHTML.renderHighlighted(markdown))
                    DispatchQueue.main.async {
                        guard let self, let webView, token == self.generation else { return }
                        webView.loadHTMLString(page, baseURL: nil)
                    }
                }
            }
            pending = item
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15, execute: item)
        }

        // After a reload, restore the scroll position to the editor's caret line.
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            sync.previewDidReload()
        }

        // Keep everything in-page: open real links in the user's browser, never navigate here.
        func webView(
            _ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction,
            decisionHandler: @escaping (WKNavigationActionPolicy) -> Void
        ) {
            if navigationAction.navigationType == .linkActivated,
                let url = navigationAction.request.url
            {
                NSWorkspace.shared.open(url)
                decisionHandler(.cancel)
            } else {
                decisionHandler(.allow)
            }
        }

        private static func page(body: String) -> String {
            """
            <!doctype html>
            <html>
            <head>
            <meta charset="utf-8">
            <meta http-equiv="Content-Security-Policy" content="default-src 'none'; style-src 'unsafe-inline'; script-src 'unsafe-inline'; img-src 'self' data:; font-src 'self'; connect-src 'none';">
            <style>\(css)</style>
            </head>
            <body>\(body)\(syncScript)</body>
            </html>
            """
        }

        /// Maps a source line to a scroll position via the `data-sourcepos` anchors.
        private static let syncScript = """
            <script>
            (function () {
              function build() {
                var arr = [];
                document.querySelectorAll('[data-sourcepos]').forEach(function (el) {
                  var m = el.getAttribute('data-sourcepos').match(/^(\\d+):/);
                  if (m) arr.push({ line: parseInt(m[1], 10), top: el.getBoundingClientRect().top + window.scrollY });
                });
                arr.sort(function (a, b) { return a.line - b.line; });
                window.__colophonAnchors = arr;
              }
              window.__colophonScrollToLine = function (line) {
                if (!window.__colophonAnchors) build();
                var a = window.__colophonAnchors;
                if (!a || !a.length) return;
                var lo = 0, hi = a.length - 1, idx = 0;
                while (lo <= hi) { var mid = (lo + hi) >> 1; if (a[mid].line <= line) { idx = mid; lo = mid + 1; } else { hi = mid - 1; } }
                var y = a[idx].top;
                if (idx + 1 < a.length && a[idx + 1].line > a[idx].line) {
                  var frac = (line - a[idx].line) / (a[idx + 1].line - a[idx].line);
                  y = a[idx].top + frac * (a[idx + 1].top - a[idx].top);
                }
                window.scrollTo(0, Math.max(0, y - window.innerHeight * 0.3));
              };
              build();
              // Rebuild anchors when any block changes height. hljs is synchronous so this is
              // a no-op today; it pre-empts scroll drift once async KaTeX/Mermaid land (M1.4.d).
              if (window.ResizeObserver) {
                new ResizeObserver(function () { window.__colophonAnchors = null; }).observe(document.body);
              }
            })();
            </script>
            """

        private static let css = """
            :root { color-scheme: light dark; }
            body {
              font-family: ui-serif, Georgia, "Times New Roman", serif;
              font-size: 17px; line-height: 1.65;
              max-width: 42em; margin: 24px auto; padding: 0 24px;
              -webkit-text-size-adjust: 100%;
            }
            h1, h2, h3, h4, h5, h6 { line-height: 1.25; margin: 1.6em 0 0.6em; }
            h1 { font-size: 1.9em; } h2 { font-size: 1.5em; } h3 { font-size: 1.25em; }
            p, ul, ol, blockquote, table, pre { margin: 0.8em 0; }
            a { color: -apple-system-blue; }
            code, pre, tt {
              font-family: ui-monospace, "SF Mono", Menlo, monospace; font-size: 0.9em;
            }
            code { background: color-mix(in srgb, currentColor 8%, transparent); padding: 0.1em 0.35em; border-radius: 4px; }
            pre { background: color-mix(in srgb, currentColor 6%, transparent); padding: 12px 14px; border-radius: 8px; overflow-x: auto; }
            pre code { background: none; padding: 0; }
            blockquote { padding-left: 1em; border-left: 3px solid color-mix(in srgb, currentColor 25%, transparent); opacity: 0.85; }
            table { border-collapse: collapse; }
            th, td { border: 1px solid color-mix(in srgb, currentColor 20%, transparent); padding: 6px 12px; }
            img { max-width: 100%; }
            hr { border: none; border-top: 1px solid color-mix(in srgb, currentColor 20%, transparent); }
            ul.contains-task-list { list-style: none; padding-left: 1em; }

            /* highlight.js tokens — GitHub light (container bg already neutralized above).
               The dark override below uses the SAME selector groups so no token is left
               unstyled in dark mode. */
            .hljs-doctag, .hljs-keyword, .hljs-meta .hljs-keyword, .hljs-template-tag, .hljs-template-variable, .hljs-type, .hljs-variable.language_ { color: #d73a49; }
            .hljs-title, .hljs-title.class_, .hljs-title.class_.inherited__, .hljs-title.function_ { color: #6f42c1; }
            .hljs-attr, .hljs-attribute, .hljs-literal, .hljs-meta, .hljs-number, .hljs-operator, .hljs-variable, .hljs-selector-attr, .hljs-selector-class, .hljs-selector-id { color: #005cc5; }
            .hljs-regexp, .hljs-string, .hljs-meta .hljs-string { color: #032f62; }
            .hljs-built_in, .hljs-symbol { color: #e36209; }
            .hljs-comment, .hljs-code, .hljs-formula { color: #6a737d; }
            .hljs-name, .hljs-quote, .hljs-selector-tag, .hljs-selector-pseudo { color: #22863a; }
            .hljs-subst { color: #24292e; }
            .hljs-section { color: #005cc5; font-weight: bold; }
            .hljs-bullet { color: #735c0f; }
            .hljs-emphasis { font-style: italic; }
            .hljs-strong { font-weight: bold; }
            .hljs-addition { color: #22863a; background: #f0fff4; }
            .hljs-deletion { color: #b31d28; background: #ffeef0; }
            @media (prefers-color-scheme: dark) {
              .hljs-doctag, .hljs-keyword, .hljs-meta .hljs-keyword, .hljs-template-tag, .hljs-template-variable, .hljs-type, .hljs-variable.language_ { color: #ff7b72; }
              .hljs-title, .hljs-title.class_, .hljs-title.class_.inherited__, .hljs-title.function_ { color: #d2a8ff; }
              .hljs-attr, .hljs-attribute, .hljs-literal, .hljs-meta, .hljs-number, .hljs-operator, .hljs-variable, .hljs-selector-attr, .hljs-selector-class, .hljs-selector-id { color: #79c0ff; }
              .hljs-regexp, .hljs-string, .hljs-meta .hljs-string { color: #a5d6ff; }
              .hljs-built_in, .hljs-symbol { color: #ffa657; }
              .hljs-comment, .hljs-code, .hljs-formula { color: #8b949e; }
              .hljs-name, .hljs-quote, .hljs-selector-tag, .hljs-selector-pseudo { color: #7ee787; }
              .hljs-subst { color: #c9d1d9; }
              .hljs-section { color: #1f6feb; font-weight: bold; }
              .hljs-bullet { color: #f2cc60; }
              .hljs-addition { color: #aff5b4; background: #033a16; }
              .hljs-deletion { color: #ffdcd7; background: #67060c; }
            }
            """
    }
}
