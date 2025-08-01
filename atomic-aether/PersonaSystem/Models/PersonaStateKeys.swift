//
//  PersonaStateKeys.swift
//  atomic-aether
//
//  StateKey definitions for persona state
//
//  ATOM 13: Persona System - State keys
//
//  Atomic LEGO: Type-safe keys for StateBus storage
//  Enables persistence of persona selections
//

import Foundation

// MARK: - Persona State Keys

extension StateKey {
    /// Current active persona (points to either Anthropic or non-Anthropic)
    static var currentPersona: StateKey<String> {
        StateKey<String>("personaState.currentPersona")
    }
    
    /// Current non-Anthropic persona (remembers last used)
    static var currentNonAnthropicPersona: StateKey<String> {
        StateKey<String>("personaState.currentNonAnthropicPersona")
    }
    
    /// Conversation history with personas (for future use)
    static var personaConversationHistory: StateKey<[String: Date]> {
        StateKey<[String: Date]>("personaState.conversationHistory")
    }
    
    /// Last interaction timestamp
    static var lastPersonaInteraction: StateKey<Date> {
        StateKey<Date>("personaState.lastInteraction")
    }
}

// MARK: - Persona Events

struct PersonaSwitchedEvent: AetherEvent, SystemEventType {
    let fromPersona: String
    let toPersona: String
    let isExplicit: Bool // true if user named persona, false if implicit
    let source: String
    
    init(from: String, to: String, explicit: Bool = true, source: String = "PersonaStateService") {
        self.fromPersona = from
        self.toPersona = to
        self.isExplicit = explicit
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