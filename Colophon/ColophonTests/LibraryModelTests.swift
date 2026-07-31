// SPDX-License-Identifier: Apache-2.0
//
//  LibraryModelTests.swift
//  ColophonTests
//
//  Integration-level checks of the M1.2 external-change decision (applyExternalChange) on the real
//  model + real temp files: a CLEAN document silently reloads in place and advances the on-disk
//  snapshot (so a later save doesn't false-abort — the BLOCKER); a DIRTY document surfaces a
//  pending banner without clobbering the user's edits; and delivering our own last-written bytes
//  is ignored (SHA-256 dedup). The LIVE presenter/reconcile firing is a manual gate (needs the
//  running sandboxed app).
//

import Foundation
import Testing

@testable import Colophon

@MainActor
struct LibraryModelTests {
    /// A fresh model with `contents` opened and loaded (waits for the deferred loadSelected).
    private func openedModel(contents: String) async throws -> (LibraryModel, URL) {
        let dir = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        let file = dir.appendingPathComponent("doc.md")
        try Data(contents.utf8).write(to: file)
        let model = LibraryModel()
        model.openFolder(dir)
        model.selectedFile = file
        try await Task.sleep(for: .milliseconds(100))  // let the deferred loadSelected run
        return (model, file)
    }

    @Test func externalChangeToCleanDocReloadsInPlaceAndAdvancesSnapshot() async throws {
        let (model, file) = try await openedModel(contents: "v1\n")
        #expect(model.document?.onDiskText == "v1\n")

        try Data("v2 external\n".utf8).write(to: file)  // an agent rewrites the file
        model.applyExternalChange(url: file, newContents: "v2 external\n")

        #expect(model.buffer.string == "v2 external\n")  // clean → silent in-place reload
        #expect(model.document?.onDiskText == "v2 external\n")  // snapshot advanced (BLOCKER)
        #expect(model.pendingExternalChange == nil)  // clean reload shows no banner
    }

    @Test func externalChangeToDirtyDocRaisesBannerWithoutClobbering() async throws {
        let (model, file) = try await openedModel(contents: "v1\n")
        model.buffer.load("my unsaved edit\n")  // simulate a dirty buffer (diverges from snapshot)
        #expect(model.isDirty)

        try Data("v2 external\n".utf8).write(to: file)
        model.applyExternalChange(url: file, newContents: "v2 external\n")

        #expect(model.buffer.string == "my unsaved edit\n")  // NOT clobbered
        #expect(model.pendingExternalChange?.diskContents == "v2 external\n")  // banner queued
    }

    @Test func selfWriteIsIgnored() async throws {
        let (model, file) = try await openedModel(contents: "v1\n")
        // Delivering our own last-written bytes as an "external" event must be a no-op (dedup).
        model.applyExternalChange(url: file, newContents: "v1\n")
        #expect(model.pendingExternalChange == nil)
        #expect(model.document?.onDiskText == "v1\n")
    }

    @Test func reconcileReloadsAfterAnExternalChange() async throws {
        let (model, file) = try await openedModel(contents: "v1\n")
        try Data("reconciled\n".utf8).write(to: file)  // changed while we weren't watching
        model.reconcileOpenDocument()  // simulate regaining focus — reads disk + applies
        #expect(model.buffer.string == "reconciled\n")
        #expect(model.document?.onDiskText == "reconciled\n")
    }

    @Test func reloadFromPendingTakesDiskAndClearsBanner() async throws {
        let (model, file) = try await openedModel(contents: "v1\n")
        model.buffer.load("my edit\n")  // dirty
        try Data("disk v2\n".utf8).write(to: file)
        model.applyExternalChange(url: file, newContents: "disk v2\n")
        #expect(model.pendingExternalChange != nil)

        model.reloadFromPending()  // banner: Reload
        #expect(model.buffer.string == "disk v2\n")
        #expect(model.document?.onDiskText == "disk v2\n")
        #expect(model.pendingExternalChange == nil)
    }

    @Test func ignorePendingKeepsEditsAndAllowsLaterSave() async throws {
        let (model, file) = try await openedModel(contents: "v1\n")
        model.buffer.load("my edit\n")  // dirty
        try Data("disk v2\n".utf8).write(to: file)
        model.applyExternalChange(url: file, newContents: "disk v2\n")

        model.ignorePending()  // banner: Ignore
        #expect(model.pendingExternalChange == nil)
        #expect(model.buffer.string == "my edit\n")  // edits kept

        // A later save now overwrites disk (last-writer-wins), no false-abort.
        model.save()
        #expect(try String(contentsOf: file, encoding: .utf8) == "my edit\n")
    }
}
