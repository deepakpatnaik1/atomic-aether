//
//  PersonaService.swift
//  atomic-aether
//
//  Persona configuration service
//
//  ATOM 9: Scrollback Message Area - Persona management
//
//  Atomic LEGO: Loads persona configuration from ConfigBus
//  Provides colors and display names for speakers
//

import Foundation
import SwiftUI
import Combine

@MainActor
class PersonaService: ObservableObject {
    @Published private(set) var personas: [String: Persona] = [:]
    
    private var configBus: ConfigBus?
    
    /// Setup with ConfigBus for hot-reloading
    func setupWithConfigBus(_ configBus: ConfigBus) {
        self.configBus = configBus
        loadPersonas()
        
        // Subscribe to configuration changes
        configBus.objectWillChange
            .sink { [weak self] _ in
                self?.loadPersonas()
            }
            .store(in: &cancellables)
    }
    
    private var cancellables = Set<AnyCancellable>()
    
    private func loadPersonas() {
        // Try new format first
        if let config = configBus?.load("Personas", as: PersonaSystemConfiguration.self) {
            // Convert to legacy format for compatibility
            var legacyPersonas: [String: Persona] = [:]
            for (id, definition) in config.personas {
                legacyPersonas[id] = Persona(
                    displayName: definition.displayName,
                    accentColor: Persona.ColorComponents(
                        red: definition.accentColor.red,
                        green: definition.accentColor.green,
                        blue: definition.accentColor.blue
                    )
                )
            }
            self.personas = legacyPersonas
        } else if let config = configBus?.load("Personas", as: PersonasConfiguration.self) {
            // Fallback to legacy format
            self.personas = config.personas
        }
    }
    
    /// Get persona for a speaker ID
    func persona(for speakerId: String) -> Persona? {
        personas[speakerId]
    }
    
    /// Get display name for a speaker
    func displayName(for speakerId: String) -> String {
        personas[speakerId]?.displayName ?? speakerId.capitalized
    }
    
    /// Get accent color for a speaker
    func accentColor(for speakerId: String) -> Color {
        personas[speakerId]?.accentColor.color ?? Color.gray
    }
}