//
//  PersonaStateService.swift
//  atomic-aether
//
//  Manages persona state with three-layer system
//
//  ATOM 10: Personas - Core state management
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
    @Published private(set) var stateConfiguration: PersonaStateConfiguration
    @Published private(set) var currentAnthropicPersona: String = ""
    @Published private(set) var currentNonAnthropicPersona: String = ""
    
    // MARK: - Dependencies
    
    private let configBus: ConfigBus
    private let stateBus: StateBus
    private let eventBus: EventBus
    private let errorBus: ErrorBus
    private let modelStateService: ModelStateService
    
    // MARK: - Private Properties
    
    private var cancellables = Set<AnyCancellable>()
    private var dynamicPersonas: [String: PersonaDefinition] = [:]
    
    // MARK: - Computed Properties
    
    /// The currently active persona (three-layer system)
    var currentPersona: String {
        get {
            stateBus.get(.currentPersona) ?? stateConfiguration.defaultNonAnthropicPersona
        }
        set {
            let oldPersona = currentPersona
            stateBus.set(.currentPersona, value: newValue)
            
            // Update last interaction
            stateBus.set(.lastPersonaInteraction, value: Date())
            
            // Publish event
            eventBus.publish(PersonaSwitchedEvent(
                fromPersona: oldPersona,
                toPersona: newValue,
                isExplicit: true
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
        self.stateConfiguration = .default
        self.currentAnthropicPersona = PersonaStateConfiguration.default.defaultAnthropicPersona
        self.currentNonAnthropicPersona = PersonaStateConfiguration.default.defaultNonAnthropicPersona
        
        // Set up subscriptions in init to avoid race conditions
        subscribeToFolderEvents()
    }
    
    // MARK: - Public Methods
    
    /// Setup method to be called after view initialization
    func setup() {
        // Load configuration
        if let loadedConfig = configBus.load("Personas", as: PersonaSystemConfiguration.self) {
            self.configuration = loadedConfig
        }
        
        // Load state configuration
        if let loadedStateConfig = configBus.load("PersonaState", as: PersonaStateConfiguration.self) {
            self.stateConfiguration = loadedStateConfig
            self.currentAnthropicPersona = loadedStateConfig.defaultAnthropicPersona
            self.currentNonAnthropicPersona = loadedStateConfig.defaultNonAnthropicPersona
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
            var potentialPersona = String(firstWord).lowercased()
            
            // Strip @ symbol if present
            if potentialPersona.hasPrefix("@") {
                potentialPersona = String(potentialPersona.dropFirst())
            }
            
            // Check if first word is a valid persona
            if configuration.isValidPersona(potentialPersona) {
                switchToPersona(potentialPersona)
                
                // Publish event (keeping existing event structure)
                eventBus.publish(PersonaMessageProcessedEvent(
                    persona: potentialPersona,
                    original: message,
                    cleaned: message
                ))
                
                return (potentialPersona, message)
            }
        }
        
        // No persona in first word, use current persona
        return (currentPersona, message)
    }
    
    /// Switch to a specific persona
    func switchToPersona(_ personaId: String) {
        guard let persona = configuration.persona(for: personaId) else {
            // Don't report error if personas haven't been loaded yet (empty configuration)
            if !configuration.personas.isEmpty {
                errorBus.report(
                    message: "Invalid persona: \(personaId)",
                    from: "PersonaStateService",
                    severity: .error
                )
            }
            return
        }
        
        if persona.isAnthropic {
            // Switching to Claude
            currentAnthropicPersona = personaId
        } else {
            // Switching to non-Anthropic persona
            currentNonAnthropicPersona = personaId
            stateBus.set(.currentNonAnthropicPersona, value: personaId)
        }
        
        // Update current persona using setter to trigger events
        currentPersona = personaId
        
        // Update conversation history
        updateConversationHistory(personaId)
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
    
    private func subscribeToFolderEvents() {
        // Subscribe to persona folder events
        eventBus.subscribe(to: PersonaFolderEvent.self) { [weak self] event in
            Task { @MainActor in
                switch event {
                case .personasLoaded(let personas):
                    self?.updateDynamicPersonas(from: personas)
                case .personaAdded(let persona):
                    self?.addDynamicPersona(persona)
                case .personaRemoved(let id):
                    self?.removeDynamicPersona(id)
                case .personaUpdated(let persona):
                    self?.updateDynamicPersona(persona)
                case .folderWatchError:
                    break // Errors already reported by folder watcher
                }
            }
        }
        .store(in: &cancellables)
    }
    
    private func updateDynamicPersonas(from personas: [PersonaFolder]) {
        // Clear existing dynamic personas
        dynamicPersonas.removeAll()
        
        // Convert PersonaFolder to PersonaDefinition and add to dictionary
        for persona in personas {
            dynamicPersonas[persona.id] = persona.toPersonaDefinition()
        }
        
        // Update configuration with dynamic personas
        var updatedConfig = configuration
        updatedConfig.personas = dynamicPersonas
        self.configuration = updatedConfig
        
        // Check if current personas still exist
        validateCurrentPersonas()
        
        // Notify UI
        objectWillChange.send()
    }
    
    private func addDynamicPersona(_ persona: PersonaFolder) {
        dynamicPersonas[persona.id] = persona.toPersonaDefinition()
        configuration.personas[persona.id] = persona.toPersonaDefinition()
        objectWillChange.send()
    }
    
    private func removeDynamicPersona(_ id: String) {
        dynamicPersonas.removeValue(forKey: id)
        configuration.personas.removeValue(forKey: id)
        
        // If removed persona was current, switch to default
        if currentPersona == id {
            switchToPersona(stateConfiguration.defaultNonAnthropicPersona)
        }
        
        objectWillChange.send()
    }
    
    private func updateDynamicPersona(_ persona: PersonaFolder) {
        dynamicPersonas[persona.id] = persona.toPersonaDefinition()
        configuration.personas[persona.id] = persona.toPersonaDefinition()
        objectWillChange.send()
    }
    
    private func validateCurrentPersonas() {
        // Check if current anthropic persona still exists
        if !configuration.isValidPersona(currentAnthropicPersona) {
            // Find first available anthropic persona
            if let firstAnthropic = configuration.anthropicPersonas.first {
                currentAnthropicPersona = firstAnthropic.id
            }
        }
        
        // Check if current non-anthropic persona still exists
        if !configuration.isValidPersona(currentNonAnthropicPersona) {
            // Find first available non-anthropic persona
            if let firstNonAnthropic = configuration.nonAnthropicPersonas.first {
                currentNonAnthropicPersona = firstNonAnthropic.id
            }
        }
        
        // Check if overall current persona still exists
        if !configuration.isValidPersona(currentPersona) {
            switchToPersona(currentNonAnthropicPersona)
        }
    }
    
    private func restoreState() {
        // Restore current persona
        if let saved = stateBus.get(.currentPersona) {
            // Validate it still exists
            if configuration.isValidPersona(saved) {
                // Don't trigger events during restore
                stateBus.set(.currentPersona, value: saved)
            } else {
                // Fallback to default
                stateBus.set(.currentPersona, value: stateConfiguration.defaultNonAnthropicPersona)
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
                currentNonAnthropicPersona = stateConfiguration.defaultNonAnthropicPersona
            }
        } else {
            currentNonAnthropicPersona = stateConfiguration.defaultNonAnthropicPersona
        }
    }
    
    private func updateConversationHistory(_ personaId: String) {
        var history = stateBus.get(.personaConversationHistory) ?? [:]
        history[personaId] = Date()
        stateBus.set(.personaConversationHistory, value: history)
    }
}