// SPDX-License-Identifier: Apache-2.0
//
//  DocumentPresenter.swift
//  Colophon
//
//  L5 single-file watcher for the OPEN document (M1.2 Increment 1 / D-M1-9). An NSFilePresenter
//  registered on the open file's URL; its callbacks arrive on a dedicated serial
//  presentedItemOperationQueue (Q_presenter). On a change, it coordinate-reads the file on a
//  SEPARATE serial queue (Q_io) — so coordinating from inside a presenter callback can't deadlock
//  the presenter queue — and delivers the decoded contents on the MAIN thread. The gate spike
//  (D-M1-15) confirmed on macOS 15 that this fires for uncoordinated external writers (echo / sed
//  / an agent's write+rename) while the app is frontmost, and that our own coordinated writes are
//  told apart by the SHA-256 sentinel. Never reads NSTextView.layoutManager.
//
//  Interop: closures (not a delegate protocol) carry events to the @MainActor model — a @MainActor
//  class can't satisfy the non-isolated NSFilePresenter/protocol requirements cleanly.
//

import Foundation

final class DocumentPresenter: NSObject, NSFilePresenter {
    let presentedItemURL: URL?
    let presentedItemOperationQueue: OperationQueue

    private let ioQueue = DispatchQueue(label: "app.colophon.document-presenter.io")
    private let onExternalChange: (String) -> Void  // invoked on MAIN with the disk contents
    private let onRemoved: () -> Void  // invoked on MAIN when the file is deleted / moved away

    init(url: URL, onExternalChange: @escaping (String) -> Void, onRemoved: @escaping () -> Void) {
        let queue = OperationQueue()
        queue.maxConcurrentOperationCount = 1
        queue.name = "app.colophon.document-presenter"
        self.presentedItemURL = url
        self.presentedItemOperationQueue = queue
        self.onExternalChange = onExternalChange
        self.onRemoved = onRemoved
        super.init()
        NSFileCoordinator.addFilePresenter(self)
    }

    /// Deterministically unregister before the folder's security scope is dropped.
    func stop() {
        NSFileCoordinator.removeFilePresenter(self)
    }

    func presentedItemDidChange() {
        guard let url = presentedItemURL else { return }
        ioQueue.async { [onExternalChange, onRemoved] in
            if !FileManager.default.fileExists(atPath: url.path) {
                DispatchQueue.main.async { onRemoved() }  // deleted / renamed under us
                return
            }
            // A coordinated read throw = "no observation" (transient) → do nothing; never a
            // reload-to-empty on a failed read.
            guard let contents = try? CoordinatedFileIO.read(url) else { return }
            DispatchQueue.main.async { onExternalChange(contents) }
        }
    }

    func accommodatePresentedItemDeletion(completionHandler: @escaping (Error?) -> Void) {
        DispatchQueue.main.async { [onRemoved] in onRemoved() }
        completionHandler(nil)
    }

    func presentedItemDidMove(to newURL: URL) {
        // An external rename/move: the file at the tracked URL is gone — surface it as a removal
        // (following the new URL in place is a later refinement).
        DispatchQueue.main.async { [onRemoved] in onRemoved() }
    }
}
