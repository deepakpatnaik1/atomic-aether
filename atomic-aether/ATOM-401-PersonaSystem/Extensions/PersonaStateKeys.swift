//
//  PersonaStateKeys.swift
//  atomic-aether
//
//  StateKey definitions for persona state
//
//  ATOM 401: Personas - State keys
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