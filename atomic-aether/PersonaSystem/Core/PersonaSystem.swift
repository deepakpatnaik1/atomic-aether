//
//  PersonaSystem.swift
//  atomic-aether
//
//  Core PersonaSystem atom coordination
//
//  ATOM 10: Personas - Core system
//
//  Atomic LEGO: Central coordinator for persona functionality
//  Manages the integration between all persona components
//

import Foundation
import SwiftUI

@MainActor
final class PersonaSystem: ObservableObject {
    
    // MARK: - Dependencies
    
    private let configBus: ConfigBus
    private let eventBus: EventBus
    private let errorBus: ErrorBus
    private let stateBus: StateBus
    
    // MARK: - Services
    
    let stateService: PersonaStateService
    let detector: PersonaDetector
    
    // MARK: - Initialization
    
    init(
        configBus: ConfigBus,
        eventBus: EventBus,
        errorBus: ErrorBus,
        stateBus: StateBus,
        modelStateService: ModelStateService
    ) {
        self.configBus = configBus
        self.eventBus = eventBus
        self.errorBus = errorBus
        self.stateBus = stateBus
        
        // Create services
        self.stateService = PersonaStateService(
            configBus: configBus,
            stateBus: stateBus,
            eventBus: eventBus,
            errorBus: errorBus,
            modelStateService: modelStateService
        )
        
        self.detector = PersonaDetector(
            configBus: configBus,
            eventBus: eventBus
        )
    }
    
    // MARK: - Public Methods
    
    /// Setup the persona system
    func setup() {
        stateService.setup()
        detector.setup()
    }
    
    /// Process a message for persona detection
    func processMessage(_ message: String) -> (persona: String, content: String) {
        return stateService.processMessage(message)
    }
    
    /// Switch to a specific persona
    func switchToPersona(_ personaId: String) {
        stateService.switchToPersona(personaId)
    }
    
    /// Get system prompt for current persona
    var currentSystemPrompt: String {
        stateService.systemPromptForCurrentPersona()
    }
    
    /// Get appropriate model for current persona
    var currentModel: String {
        stateService.modelForCurrentPersona()
    }
}