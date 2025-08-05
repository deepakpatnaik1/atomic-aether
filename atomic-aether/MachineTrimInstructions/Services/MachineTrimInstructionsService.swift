//
//  MachineTrimInstructionsService.swift
//  atomic-aether
//
//  Provides machine trim instructions for system prompt
//
//  ATOM 30: Machine Trim Instructions - Core service
//
//  Atomic LEGO: Generates instructions from configuration
//  Pure function - no state management
//

import Foundation

@MainActor
class MachineTrimInstructionsService: ObservableObject {
    // MARK: - Private Properties
    private var configuration: MachineTrimInstructionsConfiguration = .default
    
    // MARK: - Dependencies
    private var configBus: ConfigBus?
    private var eventBus: EventBus?
    private var errorBus: ErrorBus?
    private var personaStateService: PersonaStateService?
    
    // MARK: - Setup
    func setup(
        configBus: ConfigBus,
        eventBus: EventBus,
        errorBus: ErrorBus,
        personaStateService: PersonaStateService
    ) {
        self.configBus = configBus
        self.eventBus = eventBus
        self.errorBus = errorBus
        self.personaStateService = personaStateService
        
        loadConfiguration()
    }
    
    private func loadConfiguration() {
        if let config = configBus?.load("MachineTrimInstructions", as: MachineTrimInstructionsConfiguration.self) {
            self.configuration = config
        }
    }
    
    // MARK: - Public Interface
    
    /// Get formatted instructions for the current persona
    func getInstructions(for personaId: String? = nil) -> String? {
        guard configuration.enabled else {
            eventBus?.publish(MachineTrimInstructionsEvent.instructionsDisabled)
            return nil
        }
        
        let persona = personaId ?? personaStateService?.currentPersona ?? "Assistant"
        
        var instructions = configuration.instructionTemplate
            .replacingOccurrences(of: "{normalMarker}", with: configuration.normalResponseMarker)
            .replacingOccurrences(of: "{machineTrimMarker}", with: configuration.machineTrimMarker)
            .replacingOccurrences(of: "{inferableMarker}", with: configuration.inferableMarker)
            .replacingOccurrences(of: "{inferableOnlyMarker}", with: configuration.inferableOnlyMarker)
            .replacingOccurrences(of: "{persona}", with: persona)
        
        // Add examples if enabled
        if configuration.includeExamples && !configuration.examples.isEmpty {
            instructions += "\n\nEXAMPLES:\n"
            
            for (index, example) in configuration.examples.enumerated() {
                instructions += """
                
                Example \(index + 1) - \(example.description):
                
                \(configuration.normalResponseMarker)
                \(example.normalResponse)
                
                \(configuration.machineTrimMarker)
                \(example.machineTrim)
                """
            }
        }
        
        // Add inferability guidelines
        if !configuration.inferabilityGuidelines.isEmpty {
            instructions += "\n\nINFERABILITY GUIDELINES:\n"
            for guideline in configuration.inferabilityGuidelines {
                instructions += "- \(guideline)\n"
            }
        }
        
        eventBus?.publish(MachineTrimInstructionsEvent.instructionsGenerated(
            length: instructions.count,
            persona: persona
        ))
        
        return instructions
    }
    
    /// Check if instructions are enabled
    var isEnabled: Bool {
        configuration.enabled
    }
    
    /// Get the configured markers for validation
    var markers: (normal: String, trim: String) {
        (configuration.normalResponseMarker, configuration.machineTrimMarker)
    }
}