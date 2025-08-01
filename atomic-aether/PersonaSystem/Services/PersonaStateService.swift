//
//  PersonaStateService.swift
//  atomic-aether
//
//  Manages persona state with three-layer system
//
//  ATOM 13: Persona System - Core state management
//
//  Atomic LEGO: Central service for persona state
//  - Tracks current Anthropic persona (always Claude)
//  - Tracks current non-Anthropic persona
//  - Manages currentPersona pointer
//  - Persists state across sessions
//

import Foundation
import SwiftUI
import Combine

@MainActor
final class PersonaStateService: ObservableObject {
    
    // MARK: - Published Properties
    
    @Published private(set) var configuration: PersonaSystemConfiguration
    @Published private(set) var currentAnthropicPersona: String = "claude"
    @Published private(set) var currentNonAnthropicPersona: String = ""
    
    // MARK: - Dependencies
    
    private let configBus: ConfigBus
    private let stateBus: StateBus
    private let eventBus: EventBus
    private let errorBus: ErrorBus
    private let modelStateService: ModelStateService
    
    // MARK: - Computed Properties
    
    /// The currently active persona (three-layer system)
    var currentPersona: String {
        get {
            stateBus.get(.currentPersona) ?? configuration.defaultNonAnthropicPersona
        }
        set {
            let oldPersona = currentPersona
            stateBus.set(.currentPersona, value: newValue)
            
            // Update last interaction
            stateBus.set(.lastPersonaInteraction, value: Date())
            
            // Publish event
            eventBus.publish(PersonaSwitchedEvent(
                from: oldPersona,
                to: newValue,
                explicit: true
            ))
        }
    }
    
    /// Get the current persona definition
    var currentPersonaDefinition: PersonaDefinition? {
        configuration.persona(for: currentPersona)
    }
    
    /// Check if current persona is Anthropic
    var isCurrentPersonaAnthropic: Bool {
        currentPersonaDefinition?.isAnthropic ?? false
    }
    
    // MARK: - Initialization
    
    init(
        configBus: ConfigBus,
        stateBus: StateBus,
        eventBus: EventBus,
        errorBus: ErrorBus,
        modelStateService: ModelStateService
    ) {
        self.configBus = configBus
        self.stateBus = stateBus
        self.eventBus = eventBus
        self.errorBus = errorBus
        self.modelStateService = modelStateService
        
        // Initialize with safe defaults
        self.configuration = .default
        self.currentAnthropicPersona = "claude"
        self.currentNonAnthropicPersona = "samara"
    }
    
    // MARK: - Public Methods
    
    /// Setup method to be called after view initialization
    func setup() {
        // Load configuration
        if let loadedConfig = configBus.load("Personas", as: PersonaSystemConfiguration.self) {
            self.configuration = loadedConfig
        }
        
        // Restore state
        restoreState()
    }
    
    /// Process a message and extract persona if present
    func processMessage(_ message: String) -> (persona: String, content: String) {
        // Simple first-word detection
        let trimmed = message.trimmingCharacters(in: .whitespaces)
        let words = trimmed.split(separator: " ", maxSplits: 1)
        
        if let firstWord = words.first {
            let potentialPersona = String(firstWord).lowercased()
            
            // Check if first word is a valid persona
            if configuration.isValidPersona(potentialPersona) {
                switchToPersona(potentialPersona)
                
                // Get remaining message after first word
                let content = words.count > 1 ? String(words[1]) : ""
                
                // Publish event (keeping existing event structure)
                eventBus.publish(PersonaMessageProcessedEvent(
                    persona: potentialPersona,
                    original: message,
                    cleaned: content
                ))
                
                return (potentialPersona, content)
            }
        }
        
        // No persona in first word, use current persona
        return (currentPersona, message)
    }
    
    /// Switch to a specific persona
    func switchToPersona(_ personaId: String) {
        guard let persona = configuration.persona(for: personaId) else {
            errorBus.report(
                message: "Invalid persona: \(personaId)",
                from: "PersonaStateService",
                severity: .error
            )
            return
        }
        
        let previousPersona = currentPersona
        
        if persona.isAnthropic {
            // Switching to Claude
            currentAnthropicPersona = personaId
            currentPersona = personaId
        } else {
            // Switching to non-Anthropic persona
            currentNonAnthropicPersona = personaId
            stateBus.set(.currentNonAnthropicPersona, value: personaId)
            currentPersona = personaId
        }
        
        // Update conversation history
        updateConversationHistory(personaId)
        
        // Log the switch
        print("Switched from \(previousPersona) to \(personaId)")
    }
    
    /// Get system prompt for current persona
    func systemPromptForCurrentPersona() -> String {
        currentPersonaDefinition?.systemPrompt ?? ""
    }
    
    /// Get appropriate model for current persona
    func modelForCurrentPersona() -> String {
        if isCurrentPersonaAnthropic {
            return modelStateService.resolvedAnthropicModel
        } else {
            return modelStateService.resolvedNonAnthropicModel
        }
    }
    
    /// Check if a persona requires Anthropic model
    func requiresAnthropicModel(_ personaId: String) -> Bool {
        configuration.persona(for: personaId)?.requiresAnthropicModel ?? false
    }
    
    // MARK: - Private Methods
    
    private func restoreState() {
        // Restore current persona
        if let saved = stateBus.get(.currentPersona) {
            // Validate it still exists
            if configuration.isValidPersona(saved) {
                // Don't trigger events during restore
                stateBus.set(.currentPersona, value: saved)
            } else {
                // Fallback to default
                stateBus.set(.currentPersona, value: configuration.defaultNonAnthropicPersona)
            }
        } else {
            // First time - set default
            stateBus.set(.currentPersona, value: configuration.defaultNonAnthropicPersona)
        }
        
        // Restore non-Anthropic persona
        if let saved = stateBus.get(.currentNonAnthropicPersona) {
            if configuration.isValidPersona(saved) && !configuration.persona(for: saved)!.isAnthropic {
                currentNonAnthropicPersona = saved
            } else {
                currentNonAnthropicPersona = configuration.defaultNonAnthropicPersona
            }
        } else {
            currentNonAnthropicPersona = configuration.defaultNonAnthropicPersona
        }
    }
    
    private func updateConversationHistory(_ personaId: String) {
        var history = stateBus.get(.personaConversationHistory) ?? [:]
        history[personaId] = Date()
        stateBus.set(.personaConversationHistory, value: history)
    }
}