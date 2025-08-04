//
//  SystemPromptConfiguration.swift
//  atomic-aether
//
//  Configuration for system prompt assembly
//
//  ATOM 28: System Prompt Builder - Configuration model
//
//  Atomic LEGO: Defines how to build complete system prompts
//  Combines persona, boss profile, persona profile, and journal
//

import Foundation

struct SystemPromptConfiguration: Codable {
    let sectionOrder: [String]
    let sectionSeparator: String
    let includeHeaders: Bool
    let sectionHeaders: [String: String]
    let maxJournalCharacters: Int
    
    static let `default` = SystemPromptConfiguration(
        sectionOrder: ["persona", "bossProfile", "personaProfile", "journal"],
        sectionSeparator: "\n\n---\n\n",
        includeHeaders: true,
        sectionHeaders: [
            "persona": "=== PERSONA ===",
            "bossProfile": "=== USER CONTEXT ===",
            "personaProfile": "=== PERSONA CONTEXT ===",
            "journal": "=== CONVERSATION MEMORY ==="
        ],
        maxJournalCharacters: 10000
    )
    
    /// Get header for a section
    func header(for section: String) -> String? {
        guard includeHeaders else { return nil }
        return sectionHeaders[section]
    }
}