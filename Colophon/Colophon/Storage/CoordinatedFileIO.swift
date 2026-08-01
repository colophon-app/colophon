// SPDX-License-Identifier: Apache-2.0
//
//  CoordinatedFileIO.swift
//  Colophon
//
//  L5 coordinated, byte-exact file I/O for the open document (M1.2 / D-M1-8). Reads and writes
//  for a watched file go through NSFileCoordinator so our own writes and an external editor's
//  writes are serialized, and iCloud/Dropbox placeholders are materialized. Writes are atomic
//  via a same-directory temp + replaceItemAt and RETURN the SHA-256 of the exact bytes written —
//  the self-write sentinel (D-M1-9) that lets an incoming change event tell our writes from
//  external ones. NEVER mtime/inode.
//
//  Byte-exactness is unchanged from MarkdownFileIO: the text's UTF-8 bytes are written verbatim
//  (BOM / CRLF / trailing newline live in the string), and `hash(_:)` fingerprints the same
//  Data(text.utf8), so a recorded hash matches a coordinated re-read + hash of the file on disk.
//

import CryptoKit
import Foundation

enum CoordinatedFileIO {
    /// SHA-256 of a string's UTF-8 bytes — the basis the write path fingerprints with.
    static func hash(_ text: String) -> Data {
        Data(SHA256.hash(data: Data(text.utf8)))
    }

    /// Coordinated strict-UTF-8 read (materializes cloud placeholders). Throws on invalid UTF-8
    /// (never lossy) or coordination failure.
    static func read(_ url: URL, presenter: NSFilePresenter? = nil) throws -> String {
        let coordinator = NSFileCoordinator(filePresenter: presenter)
        var coordinationError: NSError?
        var outcome: Result<String, Error>?
        coordinator.coordinate(readingItemAt: url, options: [], error: &coordinationError) {
            readURL in
            outcome = Result { try MarkdownFileIO.read(readURL) }
        }
        if let coordinationError { throw coordinationError }
        return try outcome!.get()
    }

    /// Outcome of a guarded write.
    enum WriteOutcome: Equatable {
        case wrote(fingerprint: Data)
        /// The file on disk differs from what we last wrote — an external editor changed it.
        /// The write was NOT performed; `diskContents` is the current on-disk text.
        case externalChange(diskContents: String)
        /// A file we were tracking no longer exists (deleted or renamed under us). The write was
        /// NOT performed — we never silently recreate a vanished file (the user must confirm).
        case removed
    }

    /// Anti-clobber write (M1.2, the load-bearing data-safety guard). If the file still matches
    /// `expected` (the SHA-256 of the bytes we last wrote or accepted), write and return the new
    /// fingerprint. If disk DIFFERS — changed under us — do NOT overwrite; return the disk
    /// contents so the caller can surface a reload. A brand-new file (`expected == nil`) or an
    /// unreadable/absent file (transient / missing) falls through to a normal write rather than
    /// bricking saves (deletion is handled separately via the presenter).
    static func writeGuarded(
        _ text: String, to url: URL, expected: Data?, presenter: NSFilePresenter? = nil
    ) throws -> WriteOutcome {
        if let expected {
            // A tracked file that no longer exists was deleted/renamed externally — refuse to
            // silently recreate it (the user confirms via the banner).
            if !FileManager.default.fileExists(atPath: url.path) {
                return .removed
            }
            if let disk = try? read(url, presenter: presenter), hash(disk) != expected {
                return .externalChange(diskContents: disk)
            }
        }
        return .wrote(fingerprint: try write(text, to: url, presenter: presenter))
    }

    /// Coordinated atomic byte-exact write (D-M1-8). Returns SHA-256 of the bytes written.
    @discardableResult
    static func write(_ text: String, to url: URL, presenter: NSFilePresenter? = nil) throws -> Data
    {
        let data = Data(text.utf8)
        let coordinator = NSFileCoordinator(filePresenter: presenter)
        var coordinationError: NSError?
        var writeError: Error?
        coordinator.coordinate(
            writingItemAt: url, options: .forReplacing, error: &coordinationError
        ) { writeURL in
            do { try atomicReplace(data, at: writeURL) } catch { writeError = error }
        }
        if let coordinationError { throw coordinationError }
        if let writeError { throw writeError }
        return Data(SHA256.hash(data: data))
    }

    /// Same-directory temp + replaceItemAt, with a bounded retry on the transient Cocoa-513
    /// permission error and a coordinated in-place atomic fallback. Byte-exact either way.
    private static func atomicReplace(_ data: Data, at url: URL) throws {
        let temp = url.deletingLastPathComponent()
            .appendingPathComponent(".colophon-\(UUID().uuidString).tmp")
        try data.write(to: temp, options: .atomic)
        for attempt in 0..<3 {
            do {
                _ = try FileManager.default.replaceItemAt(url, withItemAt: temp)
                return
            } catch let error as NSError
                where error.domain == NSCocoaErrorDomain && error.code == 513 && attempt < 2
            {
                continue  // transient permission error — retry the replace
            } catch {
                try? FileManager.default.removeItem(at: temp)
                try data.write(to: url, options: .atomic)  // last-resort in-place atomic write
                return
            }
        }
    }
}
