//
//  ScrollbackCoordinator.swift
//  atomic-aether
//
//  Core coordinator for Scrollback atom
//
//  ATOM 15: Scrollback - Central coordinator
//
//  Atomic LEGO: Coordinates scrollback functionality
//  - Message display from MessageStore
//  - Persona colors from PersonaStateService  
//  - Boss colors from BossProfileService
//  - Configuration from ConfigBus
//

import Foundation
import SwiftUI
import Combine

@MainActor
final class ScrollbackCoordinator: ObservableObject {
    
    // MARK: - Dependencies
    
    private let configBus: ConfigBus
    private let messageStore: MessageStore
    private let personaStateService: PersonaStateService
    private let bossProfileService: BossProfileService
    
    // MARK: - Properties
    
    @Published private(set) var isSetup = false
    
    // MARK: - Initialization
    
    init(
        configBus: ConfigBus,
        messageStore: MessageStore,
        personaStateService: PersonaStateService,
        bossProfileService: BossProfileService
    ) {
        self.configBus = configBus
        self.messageStore = messageStore
        self.personaStateService = personaStateService
        self.bossProfileService = bossProfileService
    }
    
    // MARK: - Setup
    
    func setup() {
        // Scrollback is primarily a view layer
        // Dependencies are already set up by their respective atoms
        // This coordinator exists for architectural completeness
        isSetup = true
    }
    
    // MARK: - Public Interface
    
    /// Get display configuration
    func loadAppearance() -> ScrollbackAppearance? {
        configBus.load("ScrollbackAppearance", as: ScrollbackAppearance.self)
    }
    
    /// Check if scrollback should auto-scroll
    func shouldAutoScroll() -> Bool {
        // Future: Could be configuration-driven
        return true
    }
    
    /// Get speaker color
    func speakerColor(for speakerId: String) -> Color {
        if speakerId.lowercased() == "boss" {
            return bossProfileService.bossColor
        }
        
        if let persona = personaStateService.configuration.persona(for: speakerId) {
            return persona.color
        }
        
        // Default gray for unknown speakers
        return Color.gray
    }
    
    /// Get speaker display name
    func speakerDisplayName(for speakerId: String) -> String {
        if speakerId.lowercased() == "boss" {
            return bossProfileService.bossDisplayName
        }
        
        if let persona = personaStateService.configuration.persona(for: speakerId) {
            return persona.displayName
        }
        
        return speakerId.capitalized
    }
}