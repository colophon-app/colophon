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
}
