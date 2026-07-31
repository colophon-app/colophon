// SPDX-License-Identifier: Apache-2.0
//
//  CoordinatedFileIOTests.swift
//  ColophonTests
//
//  Locks the M1.2 coordinated write path (D-M1-8): a coordinated atomic write is byte-exact on
//  disk (BOM / CRLF / trailing newline preserved), round-trips through the coordinated read, and
//  the returned SHA-256 fingerprint matches hash(text) — the self-write sentinel the read-before-
//  write guard compares against. The replaceItemAt path is exercised by seeding the file first.
//

import Foundation
import Testing

@testable import Colophon

struct CoordinatedFileIOTests {
    // Same torture set as MarkdownFileIOTests.roundTripIsByteExact.
    private let samples = [
        "# Title\n\nA paragraph with **bold** and a [link](x).\n",
        "no trailing newline",
        "windows\r\nline\r\nendings\r\n",
        "mixed\nline\r\nendings\n",
        "unicode: cafe \u{2014} \u{201C}curly\u{201D} \u{2014} \u{4E2D}\u{6587} \u{1F600}\n",
        "\u{FEFF}# BOM + CRLF + no trailing\r\n\r\nsecond line\r\nlast line, no newline",
        "\u{FEFF}bom then a single LF\n",
        "",
    ]

    private func tempURL() -> URL {
        FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString + ".md")
    }

    @Test func writeIsByteExactOnDiskAndRoundTrips() throws {
        for sample in samples {
            let url = tempURL()
            defer { try? FileManager.default.removeItem(at: url) }

            // Seed so the second write exercises the replaceItemAt path, not just the create
            // fallback.
            try CoordinatedFileIO.write("seed", to: url)
            let fingerprint = try CoordinatedFileIO.write(sample, to: url)

            // On-disk bytes are exactly the UTF-8 of the string — no BOM/CRLF/trailing-newline
            // normalization.
            #expect(try Data(contentsOf: url) == Data(sample.utf8))
            // The coordinated read round-trips byte-exact.
            #expect(try CoordinatedFileIO.read(url) == sample)
            // The returned self-write fingerprint matches hash(sample).
            #expect(fingerprint == CoordinatedFileIO.hash(sample))
        }
    }

    @Test func hashDistinguishesContent() {
        #expect(CoordinatedFileIO.hash("hello") == CoordinatedFileIO.hash("hello"))
        #expect(CoordinatedFileIO.hash("hello") != CoordinatedFileIO.hash("hello "))
    }

    // MARK: - Anti-clobber guard (the load-bearing M1.2 data-safety guarantee)

    /// An external editor changed the file under us → the guard must REFUSE to write and hand back
    /// the disk contents, and the file must be left exactly as the external editor wrote it.
    @Test func writeGuardedRefusesToClobberAnExternalChange() throws {
        let url = tempURL()
        defer { try? FileManager.default.removeItem(at: url) }

        let fp = try CoordinatedFileIO.write("ours v1\n", to: url)
        // Simulate an uncoordinated external write (an agent rewriting the file).
        try Data("EXTERNAL WINS\n".utf8).write(to: url)

        let outcome = try CoordinatedFileIO.writeGuarded("ours v2\n", to: url, expected: fp)
        #expect(outcome == .externalChange(diskContents: "EXTERNAL WINS\n"))
        // The file was NOT overwritten with our stale buffer.
        #expect(try Data(contentsOf: url) == Data("EXTERNAL WINS\n".utf8))
    }

    /// No external change → the guard writes normally and returns the new fingerprint.
    @Test func writeGuardedWritesWhenUnchanged() throws {
        let url = tempURL()
        defer { try? FileManager.default.removeItem(at: url) }

        let fp1 = try CoordinatedFileIO.write("v1\n", to: url)
        let outcome = try CoordinatedFileIO.writeGuarded("v2\n", to: url, expected: fp1)
        #expect(outcome == .wrote(fingerprint: CoordinatedFileIO.hash("v2\n")))
        #expect(try CoordinatedFileIO.read(url) == "v2\n")
    }

    /// A brand-new file (no recorded fingerprint) writes without guarding.
    @Test func writeGuardedWritesNewFile() throws {
        let url = tempURL()
        defer { try? FileManager.default.removeItem(at: url) }

        let outcome = try CoordinatedFileIO.writeGuarded("new\n", to: url, expected: nil)
        #expect(outcome == .wrote(fingerprint: CoordinatedFileIO.hash("new\n")))
        #expect(try CoordinatedFileIO.read(url) == "new\n")
    }

    /// After we ACCEPT the external change (advance the fingerprint to the disk hash), the next
    /// write must succeed — no false abort (the BLOCKER: a reload/ignore must re-baseline the hash).
    @Test func writeGuardedProceedsAfterAcceptingDiskTruth() throws {
        let url = tempURL()
        defer { try? FileManager.default.removeItem(at: url) }

        _ = try CoordinatedFileIO.write("ours v1\n", to: url)
        try Data("EXTERNAL\n".utf8).write(to: url)
        // Accept disk truth: re-baseline the expected fingerprint to the current disk contents.
        let accepted = CoordinatedFileIO.hash("EXTERNAL\n")

        let outcome = try CoordinatedFileIO.writeGuarded("ours v2\n", to: url, expected: accepted)
        #expect(outcome == .wrote(fingerprint: CoordinatedFileIO.hash("ours v2\n")))
        #expect(try CoordinatedFileIO.read(url) == "ours v2\n")
    }
}
