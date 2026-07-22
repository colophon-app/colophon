// SPDX-License-Identifier: Apache-2.0
//
//  AgentFileKind.swift
//  Colophon
//
//  Recognises files that AI agents read or write as configuration / instructions
//  (CLAUDE.md, AGENTS.md, *.mdc, SKILL.md, llms.txt, …). This is the MVP's "leave a
//  door open for AI" hook (PRD §5.1 D, architecture §2.2): the editor already saves
//  these byte-exact with smart punctuation off; recognising them lets the UI mark them.
//
//  The recognition table is DATA-DRIVEN on purpose — a new convention is a row here,
//  not new code (architecture §2.2, M5). Recognition never affects how bytes are saved.
//

import Foundation

/// A category of agent-facing file. Raw values are stable identifiers, not display copy.
enum AgentFileKind: String, CaseIterable {
    case claude
    case agents
    case cursorRule
    case skill
    case llmsTxt
    case copilot
    case gemini
    case windsurf
    case cline

    /// Short label for the UI. Proper nouns / filenames — shown verbatim, not localized.
    var displayName: String {
        switch self {
        case .claude: return "Claude"
        case .agents: return "AGENTS.md"
        case .cursorRule: return "Cursor rule"
        case .skill: return "Agent Skill"
        case .llmsTxt: return "llms.txt"
        case .copilot: return "Copilot"
        case .gemini: return "Gemini"
        case .windsurf: return "Windsurf"
        case .cline: return "Cline"
        }
    }

    /// A single quiet glyph keeps the sidebar calm; the kind is named in the label, not
    /// spelled out through a zoo of icons.
    var symbolName: String { "sparkles" }
}

enum AgentFileRecognizer {
    private enum Match {
        case name(String)  // exact filename, case-insensitive
        case ext(String)  // path extension, case-insensitive
    }

    private static let rules: [(Match, AgentFileKind)] = [
        (.name("claude.md"), .claude),
        (.name("agents.md"), .agents),
        (.name("skill.md"), .skill),
        (.name("gemini.md"), .gemini),
        (.name("llms.txt"), .llmsTxt),
        (.name("llms-full.txt"), .llmsTxt),
        (.name("copilot-instructions.md"), .copilot),
        (.name(".cursorrules"), .cursorRule),
        (.name(".windsurfrules"), .windsurf),
        (.name(".clinerules"), .cline),
        (.ext("mdc"), .cursorRule),
    ]

    static func kind(for url: URL) -> AgentFileKind? {
        kind(forFilename: url.lastPathComponent)
    }

    static func kind(forFilename filename: String) -> AgentFileKind? {
        let lower = filename.lowercased()
        let ext = (lower as NSString).pathExtension
        for (match, kind) in rules {
            let matched: Bool
            switch match {
            case .name(let name): matched = (lower == name)
            case .ext(let fileExtension): matched = (ext == fileExtension)
            }
            if matched { return kind }
        }
        return nil
    }
}
