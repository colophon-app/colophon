// SPDX-License-Identifier: Apache-2.0
//
//  ColophonTests.swift
//  ColophonTests
//

import Foundation
import Testing

@testable import Colophon

struct MarkdownFileIOTests {

    private func tempURL() -> URL {
        FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString + ".md")
    }

    @Test func roundTripIsByteExact() throws {
        let samples = [
            "# Title\n\nA paragraph with **bold** and a [link](x).\n",
            "no trailing newline",
            "windows\r\nline\r\nendings\r\n",
            "mixed\nline\r\nendings\n",
            "unicode: cafe \u{2014} \u{201C}curly\u{201D} \u{2014} \u{4E2D}\u{6587} \u{1F600}\n",
            "",
        ]
        for sample in samples {
            let url = tempURL()
            defer { try? FileManager.default.removeItem(at: url) }

            try MarkdownFileIO.write(sample, to: url)
            let readBack = try MarkdownFileIO.read(url)
            #expect(readBack == sample)

            // Bytes on disk must equal the UTF-8 encoding of the input, exactly.
            let onDisk = try Data(contentsOf: url)
            #expect(onDisk == Data(sample.utf8))
        }
    }

    @Test func invalidUTF8IsRejected() throws {
        let url = tempURL()
        defer { try? FileManager.default.removeItem(at: url) }

        try Data([0xFF, 0xFE, 0xFD]).write(to: url)  // not valid UTF-8
        #expect(throws: MarkdownFileIO.IOError.self) {
            _ = try MarkdownFileIO.read(url)
        }
    }
}
