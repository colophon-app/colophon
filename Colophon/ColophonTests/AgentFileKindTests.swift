// SPDX-License-Identifier: Apache-2.0
//
//  AgentFileKindTests.swift
//  ColophonTests
//

import Foundation
import Testing

@testable import Colophon

struct AgentFileKindTests {

    @Test func recognisesKnownAgentFiles() {
        #expect(AgentFileRecognizer.kind(forFilename: "CLAUDE.md") == .claude)
        #expect(AgentFileRecognizer.kind(forFilename: "AGENTS.md") == .agents)
        #expect(AgentFileRecognizer.kind(forFilename: "SKILL.md") == .skill)
        #expect(AgentFileRecognizer.kind(forFilename: "llms.txt") == .llmsTxt)
        #expect(AgentFileRecognizer.kind(forFilename: ".cursorrules") == .cursorRule)
        #expect(AgentFileRecognizer.kind(forFilename: "style.mdc") == .cursorRule)
    }

    @Test func recognitionIsCaseInsensitive() {
        #expect(AgentFileRecognizer.kind(forFilename: "claude.md") == .claude)
        #expect(AgentFileRecognizer.kind(forFilename: "Claude.MD") == .claude)
        #expect(AgentFileRecognizer.kind(forFilename: "RULES.MDC") == .cursorRule)
    }

    @Test func ordinaryFilesAreNotAgentFiles() {
        #expect(AgentFileRecognizer.kind(forFilename: "README.md") == nil)
        #expect(AgentFileRecognizer.kind(forFilename: "notes.txt") == nil)
        #expect(AgentFileRecognizer.kind(forFilename: "index.md") == nil)
        // "claude" must be the whole name, not a substring.
        #expect(AgentFileRecognizer.kind(forFilename: "my-claude-notes.md") == nil)
    }
}
