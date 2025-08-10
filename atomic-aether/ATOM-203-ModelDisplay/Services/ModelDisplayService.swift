//
//  ModelDisplayService.swift
//  atomic-aether
//
//  Service to track and format current model display
//
//  ATOM 203: Model Display - Service
//
//  Atomic LEGO: Observes PersonaStateService for model changes
//  Provides formatted display names for UI
//

import Foundation
import SwiftUI
import Combine

@MainActor
final class ModelDisplayService: ObservableObject {
    
    // MARK: - Published Properties
    
    @Published private(set) var currentModelDisplay: String = ""
    @Published private(set) var configuration: ModelDisplayConfiguration
    
    // Track the last selected model
    private var lastSelectedModel: String?
    
    // MARK: - Dependencies
    
    private let configBus: ConfigBus
    private let eventBus: EventBus
    private let modelStateService: ModelStateService
    private let personaStateService: PersonaStateService
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initialization
    
    init(
        configBus: ConfigBus,
        eventBus: EventBus,
        modelStateService: ModelStateService,
        personaStateService: PersonaStateService
    ) {
        self.configBus = configBus
        self.eventBus = eventBus
        self.modelStateService = modelStateService
        self.personaStateService = personaStateService
        
        // Initialize with default configuration
        self.configuration = .default
        
        // Setup observers after init
        setupObservers()
    }
    
    // MARK: - Public Methods
    
    /// Setup method to be called after view initialization
    func setup() {
        // Load configuration
        if let loadedConfig = configBus.load("ModelDisplay", as: ModelDisplayConfiguration.self) {
            self.configuration = loadedConfig
        }
        
        // Update display immediately
        updateModelDisplay()
    }
    
    // MARK: - Private Methods
    
    private func setupObservers() {
        // Observe state changes for currentPersona using filtered subscription
        eventBus.subscribe(
            to: StateChangedEvent.self,
            where: { $0.key == "personaState.currentPersona" },
            handler: { [weak self] _ in
                self?.updateModelDisplay()
            }
        ).store(in: &cancellables)
        
        // Also observe persona switched events for immediate updates
        eventBus.subscribe(
            to: PersonaSwitchedEvent.self,
            handler: { [weak self] event in
                // Clear last selected model when persona switches
                self?.lastSelectedModel = nil
                self?.updateModelDisplay()
            }
        ).store(in: &cancellables)
        
        // Observe model selection events
        eventBus.subscribe(
            to: ModelSelectedEvent.self,
            handler: { [weak self] event in
                self?.lastSelectedModel = event.model
                self?.updateModelDisplay()
            }
        ).store(in: &cancellables)
    }
    
    private func updateModelDisplay() {
        // Show the last selected model if available
        // Otherwise show the model for the current persona
        let currentModel = lastSelectedModel ?? personaStateService.modelForCurrentPersona()
        
        // Format for display
        currentModelDisplay = configuration.displayName(for: currentModel)
    }
}