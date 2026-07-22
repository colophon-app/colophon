// SPDX-License-Identifier: Apache-2.0
//
//  PreviewWebView.swift
//  Colophon
//
//  L4: the split-preview pane. A WKWebView renders the cmark HTML (MarkdownHTML) inside a
//  minimal document with a strict CSP. M1.4.a slice: rendering only — no scroll sync
//  (M1.4.b), no KaTeX/Mermaid/highlight (M1.4.c). JavaScript is OFF.
//
//  Sandbox + privacy (decision D-M1-13): a sandboxed app that uses WKWebView requires the
//  `com.apple.security.network.client` entitlement — even for purely local content (the
//  WebContent/Network helper processes can't launch without it). The entitlement is present
//  but the preview makes ZERO outbound requests: the CSP sets `connect-src 'none'`, only
//  local content is loaded, and JavaScript is disabled. "No data leaves your machine" is
//  enforced, not merely intended.
//
//  L4 contract (architecture §1.2, §4): the preview is read-only downstream of the model —
//  it renders `markdown` and never writes editor state back.
//

import SwiftUI
import WebKit

struct PreviewWebView: NSViewRepresentable {
    let markdown: String

    func makeCoordinator() -> Coordinator { Coordinator() }

    func makeNSView(context: Context) -> WKWebView {
        let configuration = WKWebViewConfiguration()
        configuration.defaultWebpagePreferences.allowsContentJavaScript = false
        configuration.websiteDataStore = .nonPersistent()

        let webView = WKWebView(frame: .zero, configuration: configuration)
        webView.navigationDelegate = context.coordinator
        context.coordinator.render(markdown, in: webView)
        return webView
    }

    func updateNSView(_ webView: WKWebView, context: Context) {
        context.coordinator.render(markdown, in: webView)
    }

    final class Coordinator: NSObject, WKNavigationDelegate {
        private var lastMarkdown: String?
        private var pending: DispatchWorkItem?

        /// Debounced re-render (the editor pushes `markdown` on every keystroke).
        func render(_ markdown: String, in webView: WKWebView) {
            guard markdown != lastMarkdown else { return }
            lastMarkdown = markdown
            pending?.cancel()
            let item = DispatchWorkItem {
                let body = MarkdownHTML.render(markdown)
                webView.loadHTMLString(Self.page(body: body), baseURL: nil)
            }
            pending = item
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15, execute: item)
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
            <meta http-equiv="Content-Security-Policy" content="default-src 'none'; style-src 'unsafe-inline'; img-src 'self' data:; font-src 'self'; connect-src 'none';">
            <style>\(css)</style>
            </head>
            <body>\(body)</body>
            </html>
            """
        }

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
            """
    }
}
