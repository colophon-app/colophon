// SPDX-License-Identifier: Apache-2.0
//
//  MarkdownFileIO.swift
//  Colophon
//
//  Pure, testable file I/O for Markdown documents. Kept free of UI so it can be
//  unit-tested directly. Reads reject invalid UTF-8 rather than corrupting the
//  file; writes are atomic and byte-exact (the text is written as UTF-8 verbatim).
//

import Foundation

enum MarkdownFileIO {
    enum IOError: Error {
        case notValidUTF8
    }

    /// Reads a file as UTF-8 text, refusing (rather than lossy-decoding) invalid input.
    static func read(_ url: URL) throws -> String {
        let data = try Data(contentsOf: url)
        guard let string = String(data: data, encoding: .utf8) else {
            throw IOError.notValidUTF8
        }
        return string
    }

    /// Writes text atomically as UTF-8 bytes, with no transformation.
    static func write(_ text: String, to url: URL) throws {
        try Data(text.utf8).write(to: url, options: [.atomic])
    }
}
