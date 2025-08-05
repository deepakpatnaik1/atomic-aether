//
//  PersonaConfiguration.swift
//  atomic-aether
//
//  Configuration structure for personas
//
//  ATOM 10: Personas - Configuration model
//
//  Atomic LEGO: JSON configuration mapping
//  Loaded from Personas.json via ConfigBus
//

import Foundation

struct PersonaSystemConfiguration: Codable {
    let personas: [String: PersonaDefinition]
    let defaultNonAnthropicPersona: String
    let personaTriggerPattern: String
    
    // MARK: - Computed Properties
    
    /// All persona definitions as an array
    var allPersonas: [PersonaDefinition] {
        Array(personas.values)
    }
    
    /// Get persona by ID
    func persona(for id: String) -> PersonaDefinition? {
        personas[id.lowercased()]
    }
    
    /// Check if persona exists
    func isValidPersona(_ id: String) -> Bool {
        personas[id.lowercased()] != nil
    }
    
    /// Get all Anthropic personas
    var anthropicPersonas: [PersonaDefinition] {
        allPersonas.filter { $0.isAnthropic }
    }
    
    /// Get all non-Anthropic personas
    var nonAnthropicPersonas: [PersonaDefinition] {
        allPersonas.filter { !$0.isAnthropic }
    }
    
    /// Regex for persona detection
    var triggerRegex: NSRegularExpression? {
        try? NSRegularExpression(pattern: personaTriggerPattern, options: .caseInsensitive)
    }
    
    // MARK: - Default Configuration
    
    static let `default` = PersonaSystemConfiguration(
        personas: [:], // Will be loaded from JSON
        defaultNonAnthropicPersona: "", // Will be loaded from JSON
        personaTriggerPattern: "" // Will be loaded from JSON
    )
}

// MARK: - Legacy Support
// Note: PersonasConfiguration and Persona are already defined in PersonaModel.swift