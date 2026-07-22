// SPDX-License-Identifier: Apache-2.0
//
//  MarkdownTextView.swift
//  Colophon
//
//  A source editor bridged from AppKit. Uses TextKit 2 explicitly and NEVER touches
//  `.layoutManager` — a single read of that property silently downgrades the view to
//  TextKit 1 (macOS 26 included). The TextKit 2 accessor `.textLayoutManager` is fine.
//
//  Styling mechanism (M1.0.5a decision D-M1-4): an NSTextContentStorageDelegate vends a
//  styled NSTextParagraph on demand as TextKit lays out each paragraph. Because TextKit 2
//  lays out lazily (viewport + overdraw), styling is naturally viewport-scoped — only
//  visible paragraphs are ever styled, so large documents never pay a whole-document
//  attribute pass. The source string is never mutated (byte-exact intact; saves read
//  `textView.string`).
//
//  M1.0.5a finding: `invalidateLayout(for:)` does NOT re-vend the delegate (the paragraph
//  keeps its previous styling). Two mechanisms make dynamic styling correct instead:
//   (1) the delegate falls back to parsing the paragraph in isolation when the whole-
//       document runs are stale (mid-edit / before the async parse lands) — so headings
//       and inline styling are always correct immediately; and
//   (2) after a reparse, an `NSTextStorage.edited(.editedCharacters, changeInLength: 0)`
//       signal (guarded against re-entrancy) forces the visible paragraphs to be re-vended
//       so multi-line constructs (fenced code) upgrade to the whole-document result.
//
//  Parsing (M1 research §D2, no incremental reparse): whole-document parse, size-adaptive
//  — synchronous for small/typical docs (fresh runs before the paragraph is vended, so no
//  flash), background+debounced for large docs. The run map is the only cross-paragraph
//  state; the delegate applies it per paragraph.
//

import AppKit
import SwiftUI

struct MarkdownTextView: NSViewRepresentable {
    @Binding var text: String
    var sync: PreviewSync?

    func makeCoordinator() -> Coordinator {
        Coordinator(text: $text, sync: sync)
    }

    func makeNSView(context: Context) -> NSScrollView {
        // --- TextKit 2 stack, built by hand (never use scrollableTextView()) ---
        let contentStorage = NSTextContentStorage()
        contentStorage.delegate = context.coordinator  // lazy per-paragraph styling
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
        context.coordinator.textLayoutManager = textLayoutManager
        context.coordinator.reparse(trigger: .load)

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
            context.coordinator.reparse(trigger: .load)
        }
    }

    final class Coordinator: NSObject, NSTextViewDelegate, NSTextContentStorageDelegate {
        enum Trigger { case load, edit }

        private let text: Binding<String>
        private let sync: PreviewSync?
        weak var textView: NSTextView?
        weak var contentStorage: NSTextContentStorage?
        weak var textLayoutManager: NSTextLayoutManager?

        let baseFont = NSFont.monospacedSystemFont(ofSize: 14, weight: .regular)
        private let baseFontSize: CGFloat = 14
        private let syncMaxLength = 20_000  // below → parse synchronously (no flash)
        private let hugeMinLength = 200_000

        // The run map and the source length it was computed for (a cheap staleness proxy:
        // if the storage length no longer matches, the runs are stale → style base-only
        // until the reparse lands and re-vends).
        private var runs: [StyleRun] = []
        private var runsSourceLength = 0
        private var generation = 0
        private var pending: DispatchWorkItem?
        private var isRestyling = false  // true while we post the re-vend signal (below)

        init(text: Binding<String>, sync: PreviewSync?) {
            self.text = text
            self.sync = sync
        }

        // MARK: - NSTextViewDelegate

        func textDidChange(_ notification: Notification) {
            guard !isRestyling, let textView = notification.object as? NSTextView else { return }
            text.wrappedValue = textView.string
            reparse(trigger: .edit)
        }

        /// Report the caret's 1-based source line so the preview can follow it (M1.4.b).
        func textViewDidChangeSelection(_ notification: Notification) {
            guard let sync, let textView = notification.object as? NSTextView else { return }
            let string = textView.string as NSString
            let offset = min(textView.selectedRange().location, string.length)
            let line = string.substring(to: offset).reduce(1) { $1 == "\n" ? $0 + 1 : $0 }
            sync.caretMoved(toLine: line)
        }

        // MARK: - NSTextContentStorageDelegate (lazy per-paragraph styling)

        func textContentStorage(
            _ textContentStorage: NSTextContentStorage, textParagraphWith range: NSRange
        ) -> NSTextParagraph? {
            guard let storage = textContentStorage.textStorage else { return nil }
            let paragraph = NSMutableAttributedString(
                attributedString: storage.attributedSubstring(from: range))
            let local = NSRange(location: 0, length: paragraph.length)
            paragraph.setAttributes(
                [.font: baseFont, .foregroundColor: NSColor.labelColor], range: local)

            if storage.length == runsSourceLength {
                // Whole-document runs are current — fully correct (handles fenced code, etc.).
                for run in runs {
                    let intersection = NSIntersectionRange(run.range, range)
                    if intersection.length > 0 {
                        let localRange = NSRange(
                            location: intersection.location - range.location,
                            length: intersection.length)
                        paragraph.addAttributes(run.attributes, range: localRange)
                    }
                }
            } else {
                // Runs are stale (mid-edit, or before the initial async parse landed). Parse
                // THIS paragraph in isolation for immediate, correct heading/inline styling.
                // Its runs are already paragraph-local. (Fenced code spanning paragraphs is
                // upgraded once the whole-document runs land and re-vend — see below.)
                let paraRuns = MarkdownSyntaxStyler.styleRuns(
                    for: paragraph.string, baseFontSize: baseFontSize)
                for run in paraRuns where NSMaxRange(run.range) <= paragraph.length {
                    paragraph.addAttributes(run.attributes, range: run.range)
                }
            }
            return NSTextParagraph(attributedString: paragraph)
        }

        // MARK: - Parse + invalidate

        func reparse(trigger: Trigger) {
            pending?.cancel()
            guard let source = textView?.string else { return }
            let length = (source as NSString).length

            // Small/typical docs: parse synchronously so runs are fresh before the edited
            // paragraph is re-vended — no flash.
            if length <= syncMaxLength {
                generation += 1
                runs = MarkdownSyntaxStyler.styleRuns(for: source, baseFontSize: baseFontSize)
                runsSourceLength = length
                invalidateStyling()
                return
            }

            let delay: TimeInterval
            switch trigger {
            case .load: delay = 0
            case .edit: delay = length > hugeMinLength ? 0.4 : 0.12
            }
            let item = DispatchWorkItem { [weak self] in self?.reparseInBackground() }
            pending = item
            DispatchQueue.main.asyncAfter(deadline: .now() + delay, execute: item)
        }

        private func reparseInBackground() {
            guard let source = textView?.string else { return }
            generation += 1
            let generationAtStart = generation
            let size = baseFontSize
            DispatchQueue.global(qos: .userInitiated).async { [weak self] in
                let computed = MarkdownSyntaxStyler.styleRuns(for: source, baseFontSize: size)
                DispatchQueue.main.async {
                    guard let self, generationAtStart == self.generation,
                        self.textView?.string == source
                    else { return }
                    self.runs = computed
                    self.runsSourceLength = (source as NSString).length
                    self.invalidateStyling()
                }
            }
        }

        /// Force the content-storage delegate to re-vend the visible paragraphs so fresh
        /// whole-document runs take effect. `invalidateLayout(for:)` does NOT re-vend
        /// (M1.0.5a finding); signalling a zero-length character edit does — the content
        /// storage re-creates the affected text elements via the delegate. The source
        /// string is unchanged (changeInLength: 0), so byte-exactness is preserved. The
        /// `isRestyling` flag stops the resulting notification from re-entering as an edit.
        private func invalidateStyling() {
            guard let storage = contentStorage?.textStorage, let textView else { return }
            let full = storage.length
            guard full > 0 else { return }
            let visible = visibleCharacterRange() ?? NSRange(location: 0, length: full)
            let clamped = NSIntersectionRange(visible, NSRange(location: 0, length: full))
            guard clamped.length > 0 else { return }
            // The zero-length character-edit signal makes the text system think characters
            // changed and moves the insertion point. Save the selection and put it back so
            // the caret does not jump.
            let savedSelection = textView.selectedRanges
            isRestyling = true
            storage.beginEditing()
            storage.edited(.editedCharacters, range: clamped, changeInLength: 0)
            storage.endEditing()
            textView.selectedRanges = savedSelection
            isRestyling = false
        }

        private func visibleCharacterRange() -> NSRange? {
            guard let content = contentStorage,
                let viewport = textLayoutManager?.textViewportLayoutController.viewportRange
            else { return nil }
            let start = content.offset(from: content.documentRange.location, to: viewport.location)
            let end = content.offset(from: content.documentRange.location, to: viewport.endLocation)
            guard start >= 0, end >= start else { return nil }
            return NSRange(location: start, length: end - start)
        }
    }
}
