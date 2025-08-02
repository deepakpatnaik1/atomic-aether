//
//  ModelDisplayService.swift
//  atomic-aether
//
//  Service to track and format current model display
//
//  ATOM 18: Dynamic Model Display - Service
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
    
    // MARK: - Dependencies
    
    private let configBus: ConfigBus
    private let personaStateService: PersonaStateService
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initialization
    
    init(
        configBus: ConfigBus,
        personaStateService: PersonaStateService
    ) {
        self.configBus = configBus
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
        // Observe configuration changes
        personaStateService.$configuration
            .sink { [weak self] _ in
                self?.updateModelDisplay()
            }
            .store(in: &cancellables)
        
        // Observe Anthropic persona changes
        personaStateService.$currentAnthropicPersona
            .sink { [weak self] _ in
                self?.updateModelDisplay()
            }
            .store(in: &cancellables)
        
        // Observe non-Anthropic persona changes
        personaStateService.$currentNonAnthropicPersona
            .sink { [weak self] _ in
                self?.updateModelDisplay()
            }
            .store(in: &cancellables)
    }
    
    private func updateModelDisplay() {
        // Get current model from persona state
        let currentModel = personaStateService.modelForCurrentPersona()
        
        // Format for display
        currentModelDisplay = configuration.displayName(for: currentModel)
    }
}