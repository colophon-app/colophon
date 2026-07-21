// SPDX-License-Identifier: Apache-2.0
//
//  MarkdownTextView.swift
//  Colophon
//
//  A source editor bridged from AppKit. Uses TextKit 2 explicitly and NEVER touches
//  `.layoutManager` — a single read of that property silently downgrades the view to
//  TextKit 1 (macOS 26 included).
//
//  M1.0 spike: applies swift-markdown AST-driven *source styling* (MarkdownSyntaxStyler)
//  as display attributes. The source string is never mutated, so byte-exact saving is
//  untouched (saves read `textView.string`, never attributes).
//
//  Performance (M1 research §D2): swift-markdown has NO incremental reparse, so styling
//  cost scales with document size. Strategy is size-adaptive:
//    • small/typical docs  → style SYNCHRONOUSLY on edit (a few ms) so a freshly typed
//      character appears already-styled — no debounce "flash to size";
//    • larger docs         → parse off the main thread on a debounce (longer for very
//      large docs) so active typing never blocks; styling catches up when typing pauses.
//  Whole-document attribute application keeps scrolling smooth (no per-scroll restyle).
//  Viewport-scoped and incremental styling for multi-MB files is an M1.1 optimization.
//
//  Attribute-application mechanism (M1.0.5 decision D-M1-4): direct `addAttributes` on
//  the content storage's backing NSTextStorage (reliable redraw). The
//  NSTextContentStorageDelegate display-attribute path is the M1.0.5 spike's job.
//

import AppKit
import SwiftUI

struct MarkdownTextView: NSViewRepresentable {
    @Binding var text: String

    func makeCoordinator() -> Coordinator {
        Coordinator(text: $text)
    }

    func makeNSView(context: Context) -> NSScrollView {
        // --- TextKit 2 stack, built by hand (never use scrollableTextView()) ---
        let contentStorage = NSTextContentStorage()
        let textLayoutManager = NSTextLayoutManager()
        contentStorage.addTextLayoutManager(textLayoutManager)

        let container = NSTextContainer(
            size: NSSize(width: 0, height: CGFloat.greatestFiniteMagnitude))
        container.widthTracksTextView = true
        textLayoutManager.textContainer = container

        let textView = NSTextView(frame: .zero, textContainer: container)
        textView.delegate = context.coordinator
        textView.string = text

        textView.isRichText = false
        textView.allowsUndo = true
        textView.usesFontPanel = false
        textView.usesRuler = false

        // Byte-exact: no smart substitutions.
        textView.isAutomaticQuoteSubstitutionEnabled = false
        textView.isAutomaticDashSubstitutionEnabled = false
        textView.isAutomaticTextReplacementEnabled = false
        textView.isAutomaticSpellingCorrectionEnabled = false
        textView.smartInsertDeleteEnabled = false

        textView.font = context.coordinator.baseFont
        textView.textContainerInset = NSSize(width: 16, height: 16)

        textView.minSize = NSSize(width: 0, height: 0)
        textView.maxSize = NSSize(
            width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude)
        textView.isVerticallyResizable = true
        textView.isHorizontallyResizable = false
        textView.autoresizingMask = [.width]

        context.coordinator.textView = textView
        context.coordinator.contentStorage = contentStorage
        context.coordinator.applyStyling(source: .load)

        let scrollView = NSScrollView()
        scrollView.documentView = textView
        scrollView.hasVerticalScroller = true
        scrollView.autohidesScrollers = true
        scrollView.borderType = .noBorder
        return scrollView
    }

    func updateNSView(_ scrollView: NSScrollView, context: Context) {
        guard let textView = scrollView.documentView as? NSTextView else { return }
        // Only write back on a real change (avoids an update loop and caret jumps).
        if textView.string != text {
            textView.string = text
            context.coordinator.applyStyling(source: .load)
        }
    }

    final class Coordinator: NSObject, NSTextViewDelegate {
        enum StyleTrigger { case load, edit }

        private let text: Binding<String>
        weak var textView: NSTextView?
        weak var contentStorage: NSTextContentStorage?

        let baseFont = NSFont.monospacedSystemFont(ofSize: 14, weight: .regular)
        private let baseFontSize: CGFloat = 14

        // Size adaptivity (UTF-16 units).
        private let syncMaxLength = 20_000  // below → style synchronously (no flash)
        private let hugeMinLength = 200_000  // above → long debounce (smooth active typing)

        private var styleGeneration = 0
        private var pending: DispatchWorkItem?

        init(text: Binding<String>) {
            self.text = text
        }

        func textDidChange(_ notification: Notification) {
            guard let textView = notification.object as? NSTextView else { return }
            text.wrappedValue = textView.string
            applyStyling(source: .edit)
        }

        func applyStyling(source trigger: StyleTrigger) {
            pending?.cancel()
            guard let text = textView?.string else { return }
            let length = (text as NSString).length

            // Small/typical documents: style synchronously so a freshly typed character
            // is already the right size — no debounce flash.
            if length <= syncMaxLength {
                styleGeneration += 1
                let runs = MarkdownSyntaxStyler.styleRuns(for: text, baseFontSize: baseFontSize)
                render(runs: runs, expecting: text)
                return
            }

            // Larger documents: parse off the main thread. Load is immediate; edits are
            // debounced — longer for very large docs so active typing never blocks.
            let delay: TimeInterval
            switch trigger {
            case .load: delay = 0
            case .edit: delay = length > hugeMinLength ? 0.6 : 0.12
            }
            let item = DispatchWorkItem { [weak self] in self?.parseInBackground() }
            pending = item
            DispatchQueue.main.asyncAfter(deadline: .now() + delay, execute: item)
        }

        private func parseInBackground() {
            guard let source = textView?.string else { return }
            styleGeneration += 1
            let generation = styleGeneration
            let size = baseFontSize
            DispatchQueue.global(qos: .userInitiated).async { [weak self] in
                let runs = MarkdownSyntaxStyler.styleRuns(for: source, baseFontSize: size)
                DispatchQueue.main.async {
                    guard let self, generation == self.styleGeneration else { return }
                    self.render(runs: runs, expecting: source)
                }
            }
        }

        /// Apply base attributes + the runs over the whole document. Skips if the buffer
        /// changed since the runs were computed (never applies stale ranges).
        private func render(runs: [StyleRun], expecting source: String) {
            guard let storage = contentStorage?.textStorage, let textView,
                textView.string == source
            else { return }
            let full = NSRange(location: 0, length: (source as NSString).length)
            storage.beginEditing()
            storage.setAttributes(
                [.font: baseFont, .foregroundColor: NSColor.labelColor], range: full)
            for run in runs where NSMaxRange(run.range) <= full.length {
                storage.addAttributes(run.attributes, range: run.range)
            }
            storage.endEditing()
        }
    }
}
