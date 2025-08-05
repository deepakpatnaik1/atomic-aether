//
//  PersonaStateConfiguration.swift
//  atomic-aether
//
//  Configuration for PersonaStateService
//
//  ATOM 10: Personas - State service configuration
//
//  Atomic LEGO: Externalize all hardcoded defaults
//  Loaded from JSON via ConfigBus
//

import Foundation

struct PersonaStateConfiguration: Codable {
    let defaultAnthropicPersona: String
    let defaultNonAnthropicPersona: String
}

extension PersonaStateConfiguration {
    static let `default` = PersonaStateConfiguration(
        defaultAnthropicPersona: "claude",
        defaultNonAnthropicPersona: "samara"
    )
}