// SPDX-License-Identifier: Apache-2.0
//
//  TextBuffer.swift
//  Colophon
//
//  L2's in-memory single source of truth for the open document's text (architecture §2.2 /
//  D-M1-1). TextBuffer strong-owns one stock NSTextStorage; the editor injects it into its
//  hand-built TextKit 2 stack (`contentStorage.textStorage = buffer.storage`), so typing
//  mutates it in place — no per-keystroke whole-string copy through a SwiftUI @Binding.
//
//  Change is detected HERE, at the source of truth, via NSTextStorageDelegate.didProcessEditing
//  (so it also fires for future programmatic / AI edits), and published as a payload-free
//  `changed` signal that the preview and autosave debounce off. The buffer also hosts the
//  document's UndoManager (returned from the editor's undoManager(for:)), so a file switch
//  (load) clears exactly the undo stack the text view registers into.
//
//  Main-thread by construction (like PreviewSync): all edits + the delegate callback happen on
//  the main thread, so it is a plain class rather than @MainActor — which would clash with the
//  non-isolated NSTextStorageDelegate requirement.
//

import AppKit
import Combine

final class TextBuffer: NSObject, NSTextStorageDelegate {
    /// The authoritative text. `.string` is the byte-exact Markdown source that save() writes.
    let storage = NSTextStorage()
    /// The open document's undo stack — the editor returns this from `undoManager(for:)`, so
    /// load()'s `removeAllActions()` clears exactly the stack the text view registers into.
    let undoManager = UndoManager()

    /// Payload-free "the text changed" signal (preview + autosave subscribe and debounce).
    let changed = PassthroughSubject<Void, Never>()
    /// Fired after load() swaps in new content, so the editor can restyle the whole document.
    let contentReloaded = PassthroughSubject<Void, Never>()
    /// Fired after an external on-disk change is reloaded in place (M1.2), so the editor can
    /// restyle WITHOUT resetting the caret to the top (unlike contentReloaded).
    let externallyReloaded = PassthroughSubject<Void, Never>()

    /// Set by the editor so didProcessEditing can consult live IME composition state.
    weak var editorView: NSTextView?
    /// True while the editor posts its zero-length styling re-vend — suppresses `changed`.
    var isApplyingStyleRevend = false
    private var isLoading = false

    private let baseFont = NSFont.monospacedSystemFont(ofSize: 14, weight: .regular)

    var string: String { storage.string }

    override init() {
        super.init()
        storage.delegate = self
    }

    /// Replace the whole buffer with `text` (opening / switching files), IN PLACE — the editor's
    /// injected storage identity is unchanged, so the live TextKit 2 stack and scroll position
    /// survive. Clears the undo stack (a file switch is not undoable) and asks the editor to
    /// restyle. Does NOT emit `changed` (a load is not a user edit, so it must not mark dirty
    /// or arm autosave).
    func load(_ text: String) {
        isLoading = true
        storage.beginEditing()
        storage.replaceCharacters(in: NSRange(location: 0, length: storage.length), with: text)
        storage.setAttributes(
            [.font: baseFont, .foregroundColor: NSColor.labelColor],
            range: NSRange(location: 0, length: storage.length))
        storage.endEditing()
        isLoading = false
        undoManager.removeAllActions()
        contentReloaded.send()  // strictly after endEditing() returns
    }

    /// Reload the buffer from an external on-disk change (M1.2), IN PLACE. Unlike load(): the undo
    /// stack is PRESERVED and the reload is itself ONE undoable step (Cmd-Z restores the user's
    /// pre-reload text), and the selection is kept (clamped to the new length) rather than reset to
    /// the top. Emits NO `changed` (the model advances the on-disk snapshot; a reload must not
    /// re-arm autosave or mark dirty on its own). Returns false without touching the buffer if the
    /// editor is mid-IME-composition (the caller should defer) or the text already matches.
    @discardableResult
    func reloadPreservingSelection(_ text: String) -> Bool {
        guard editorView?.hasMarkedText() != true else { return false }
        let oldText = storage.string
        guard oldText != text else { return false }

        let savedRanges = editorView?.selectedRanges
        editorView?.breakUndoCoalescing()
        undoManager.registerUndo(withTarget: self) { target in
            _ = target.reloadPreservingSelection(oldText)
        }

        isLoading = true
        storage.beginEditing()
        storage.replaceCharacters(in: NSRange(location: 0, length: storage.length), with: text)
        storage.setAttributes(
            [.font: baseFont, .foregroundColor: NSColor.labelColor],
            range: NSRange(location: 0, length: storage.length))
        storage.endEditing()
        isLoading = false

        if let editorView, let savedRanges {
            let length = storage.length
            editorView.selectedRanges = savedRanges.map { value in
                let range = value.rangeValue
                let location = min(range.location, length)
                return NSValue(
                    range: NSRange(location: location, length: min(range.length, length - location))
                )
            }
        }
        externallyReloaded.send()
        return true
    }

    /// Emit a change explicitly — used by the editor when IME composition ends (the committed
    /// text's own edit was suppressed while `hasMarkedText()` was true).
    func emitChanged() { changed.send() }

    // MARK: - NSTextStorageDelegate

    func textStorage(
        _ textStorage: NSTextStorage, didProcessEditing editedMask: NSTextStorageEditActions,
        range editedRange: NSRange, changeInLength delta: Int
    ) {
        guard editedMask.contains(.editedCharacters) else { return }
        guard !isLoading, !isApplyingStyleRevend else { return }
        // Suppress edits made mid-IME-composition (they would flicker the preview); the editor
        // re-emits once composition ends.
        if editorView?.hasMarkedText() == true { return }
        changed.send()
    }
}
