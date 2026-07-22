// SPDX-License-Identifier: Apache-2.0
//
//  PreviewSync.swift
//  Colophon
//
//  L1 coordination: keeps the preview scrolled to the editor's caret (editor → preview
//  follow). The editor reports the caret's 1-based source line; the preview scrolls to the
//  matching `data-sourcepos` anchor (emitted by cmark's SOURCEPOS). One-directional, so
//  there is no scroll feedback loop. Reading the editor's *scroll* position from TextKit 2
//  (for full bidirectional sync) is the fiddlier follow-up (M1 research §2/§3).
//

import Foundation
import WebKit

/// A shared reference between the editor and the preview (all methods are called on the
/// main thread by construction). Not an ObservableObject — used for direct calls, not
/// observation.
final class PreviewSync {
    weak var webView: WKWebView?
    private(set) var line = 1

    /// The editor caret moved to `line` (1-based). Scroll the preview to follow it.
    func caretMoved(toLine line: Int) {
        guard line != self.line else { return }
        self.line = line
        scrollPreview()
    }

    /// Re-apply after the preview reloads (loadHTMLString resets scroll to the top).
    func previewDidReload() {
        scrollPreview()
    }

    /// A new file loaded — the preview should start at the top, not chase the previous file's
    /// caret line. (The subsequent reload's `previewDidReload` then scrolls to line 1.)
    func resetToTop() {
        line = 1
    }

    private func scrollPreview() {
        webView?.evaluateJavaScript(
            "window.__colophonScrollToLine && window.__colophonScrollToLine(\(line))")
    }
}
