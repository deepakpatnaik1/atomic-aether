//
//  ModelPickerService.swift
//  atomic-aether
//
//  Service to manage model picker state and selection
//
//  ATOM 8: Model Picker - Service
//
//  Atomic LEGO: Coordinates model selection between UI and ModelStateService
//  Groups models by provider for display
//

import Foundation
import SwiftUI
import Combine

@MainActor
final class ModelPickerService: ObservableObject {
    
    // MARK: - Model Group
    
    struct ModelGroup {
        let provider: String
        let models: [ModelItem]
    }
    
    struct ModelItem {
        let id: String
        let displayName: String
        let isSelected: Bool
    }
    
    // MARK: - Published Properties
    
    @Published private(set) var modelGroups: [ModelGroup] = []
    @Published private(set) var configuration: ModelPickerConfiguration
    
    // MARK: - Dependencies
    
    private let configBus: ConfigBus
    private let modelStateService: ModelStateService
    private let modelDisplayService: ModelDisplayService
    private let personaStateService: PersonaStateService
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initialization
    
    init(
        configBus: ConfigBus,
        modelStateService: ModelStateService,
        modelDisplayService: ModelDisplayService,
        personaStateService: PersonaStateService
    ) {
        self.configBus = configBus
        self.modelStateService = modelStateService
        self.modelDisplayService = modelDisplayService
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
        if let loadedConfig = configBus.load("ModelPicker", as: ModelPickerConfiguration.self) {
            self.configuration = loadedConfig
        }
        
        // Build initial model groups
        updateModelGroups()
    }
    
    /// Select a model
    func selectModel(_ modelId: String) {
        modelStateService.selectModel(modelId)
    }
    
    // MARK: - Private Methods
    
    private func setupObservers() {
        // Observe persona changes - since currentPersona is computed, observe the service's objectWillChange
        personaStateService.objectWillChange
            .sink { [weak self] _ in
                // Small delay to ensure state has updated
                DispatchQueue.main.async {
                    self?.updateModelGroups()
                }
            }
            .store(in: &cancellables)
        
        // Observe default model changes
        modelStateService.$currentDefaultAnthropicModel
            .sink { [weak self] _ in
                DispatchQueue.main.async {
                    self?.updateModelGroups()
                }
            }
            .store(in: &cancellables)
        
        modelStateService.$currentDefaultNonAnthropicModel
            .sink { [weak self] _ in
                DispatchQueue.main.async {
                    self?.updateModelGroups()
                }
            }
            .store(in: &cancellables)
        
        // Observe current model changes
        modelStateService.$currentAnthropicModel
            .sink { [weak self] _ in
                DispatchQueue.main.async {
                    self?.updateModelGroups()
                }
            }
            .store(in: &cancellables)
        
        modelStateService.$currentNonAnthropicModel
            .sink { [weak self] _ in
                DispatchQueue.main.async {
                    self?.updateModelGroups()
                }
            }
            .store(in: &cancellables)
    }
    
    private func updateModelGroups() {
        let currentModel = personaStateService.modelForCurrentPersona()
        let anthropicModels = modelStateService.availableModels(anthropic: true)
        let nonAnthropicModels = modelStateService.availableModels(anthropic: false)
        let allModels = anthropicModels + nonAnthropicModels
        
        if configuration.groupByProvider {
            // Group models by provider
            var providerGroups: [String: [String]] = [:]
            
            for modelId in allModels {
                let provider = extractProvider(from: modelId)
                providerGroups[provider, default: []].append(modelId)
            }
            
            // Create model groups in configured order
            let sortedProviders = configuration.sortedProviders(from: Array(providerGroups.keys))
            
            modelGroups = sortedProviders.compactMap { provider in
                guard let models = providerGroups[provider] else { return nil }
                
                let items = models.map { modelId in
                    ModelItem(
                        id: modelId,
                        displayName: modelDisplayService.configuration.displayName(for: modelId),
                        isSelected: modelId == currentModel
                    )
                }
                
                return ModelGroup(provider: provider.capitalized, models: items)
            }
        } else {
            // Single group with all models
            let items = allModels.map { modelId in
                ModelItem(
                    id: modelId,
                    displayName: modelDisplayService.configuration.displayName(for: modelId),
                    isSelected: modelId == currentModel
                )
            }
            
            modelGroups = [ModelGroup(provider: configuration.allModelsLabel, models: items)]
        }
    }
    
    private func extractProvider(from modelId: String) -> String {
        let separator = Character(configuration.providerSeparator)
        let components = modelId.split(separator: separator)
        return components.first.map(String.init) ?? configuration.unknownProviderLabel
    }
}