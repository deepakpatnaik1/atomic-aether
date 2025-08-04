//
//  SystemPromptEvents.swift
//  atomic-aether
//
//  Events published by system prompt builder
//
//  ATOM 28: System Prompt Builder - Event definitions
//
//  Atomic LEGO: Minimal events for prompt building
//  Track what gets included/excluded
//

import Foundation

enum SystemPromptEvent: AetherEvent {
    case promptBuilt(personaId: String, length: Int)
    case sectionOmitted(section: String, reason: String)
    
    var source: String {
        "SystemPromptBuilder"
    }
    
    var id: String {
        switch self {
        case .promptBuilt:
            return "system.prompt.built"
        case .sectionOmitted:
            return "system.prompt.section.omitted"
        }
    }
    
    var metadata: [String: Any] {
        switch self {
        case .promptBuilt(let personaId, let length):
            return ["personaId": personaId, "length": length]
        case .sectionOmitted(let section, let reason):
            return ["section": section, "reason": reason]
        }
    }
}