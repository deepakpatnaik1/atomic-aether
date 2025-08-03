//
//  PersonaUIConfiguration.swift
//  atomic-aether
//
//  Configuration for persona UI strings
//
//  ATOM 10: Personas - UI configuration
//
//  Atomic LEGO: UI labels and tooltips configuration
//  Loaded from PersonaUI.json via ConfigBus
//

import Foundation

struct PersonaUIConfiguration: Codable {
    let labels: Labels
    let tooltips: Tooltips
    
    struct Labels: Codable {
        let customModelIndicator: String
        let anthropicSection: String
        let otherPersonasSection: String
    }
    
    struct Tooltips: Codable {
        let currentPersona: String
        let talkingTo: String
    }
    
    // MARK: - Helper Methods
    
    func currentPersonaTooltip(for persona: String) -> String {
        tooltips.currentPersona.replacingOccurrences(of: "{persona}", with: persona)
    }
    
    func talkingToTooltip(for persona: String) -> String {
        tooltips.talkingTo.replacingOccurrences(of: "{persona}", with: persona)
    }
    
    // MARK: - Default Configuration
    
    static let `default` = PersonaUIConfiguration(
        labels: Labels(
            customModelIndicator: "Custom",
            anthropicSection: "Anthropic",
            otherPersonasSection: "Other Personas"
        ),
        tooltips: Tooltips(
            currentPersona: "Current persona: {persona}",
            talkingTo: "Talking to: {persona}"
        )
    )
}