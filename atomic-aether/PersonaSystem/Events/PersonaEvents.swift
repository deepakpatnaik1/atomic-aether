//
//  PersonaEvents.swift
//  atomic-aether
//
//  Events for persona system
//
//  ATOM 10: Personas - Event definitions
//
//  Atomic LEGO: All persona-related events in one place
//  Clean separation from state keys
//

import Foundation

// MARK: - Persona Events

struct PersonaSwitchedEvent: AetherEvent, SystemEventType {
    let fromPersona: String
    let toPersona: String
    let isExplicit: Bool // true if user named persona, false if implicit
    let source: String
    
    init(fromPersona: String, toPersona: String, isExplicit: Bool = true, source: String = "PersonaStateService") {
        self.fromPersona = fromPersona
        self.toPersona = toPersona
        self.isExplicit = isExplicit
        self.source = source
    }
}

struct PersonaMessageProcessedEvent: AetherEvent, ConversationEventType {
    let persona: String
    let originalMessage: String
    let cleanedMessage: String
    let source: String
    
    init(persona: String, original: String, cleaned: String, source: String = "PersonaDetector") {
        self.persona = persona
        self.originalMessage = original
        self.cleanedMessage = cleaned
        self.source = source
    }
}

struct InvalidPersonaEvent: AetherEvent, SystemEventType {
    let attemptedPersona: String
    let message: String
    let source: String
    
    init(attempted: String, message: String, source: String = "PersonaStateService") {
        self.attemptedPersona = attempted
        self.message = message
        self.source = source
    }
}