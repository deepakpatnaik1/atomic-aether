//
//  ModelRegistryService.swift
//  atomic-aether
//
//  Service to manage and validate model definitions
//
//  ATOM 9: Models - Registry service for LLM models
//
//  Atomic LEGO: Service that loads and validates model configurations
//  Provides centralized model validation and registry
//

import Foundation
import SwiftUI

@MainActor
final class ModelRegistryService: ObservableObject {
    @Published private(set) var availableProviders: [LLMProvider] = []
    @Published private(set) var configuration: LLMConfiguration?
    
    private let configBus: ConfigBus
    private let eventBus: EventBus?
    
    init(configBus: ConfigBus, eventBus: EventBus? = nil) {
        self.configBus = configBus
        self.eventBus = eventBus
        loadConfiguration()
    }
    
    private func loadConfiguration() {
        configuration = configBus.load("LLMProviders", as: LLMConfiguration.self)
        
        if let config = configuration {
            availableProviders = Array(config.providers.keys.compactMap(LLMProvider.init))
            
            // Publish event when models are loaded
            eventBus?.publish(ModelEvents.modelsLoaded(providers: availableProviders))
        }
    }
    
    /// Check if a model string is valid
    func isValidModel(_ modelString: String) -> Bool {
        guard let provider = LLMProvider.from(modelString: modelString),
              let config = configuration?.providers[provider.rawValue] else {
            eventBus?.publish(ModelEvents.validationFailed(modelString: modelString))
            return false
        }
        
        let modelName = LLMProvider.extractModelName(from: modelString)
        return config.models.keys.contains(modelName)
    }
    
    /// Get configuration for a specific provider
    func providerConfig(for provider: LLMProvider) -> ProviderConfig? {
        return configuration?.providers[provider.rawValue]
    }
    
    /// Get all available models for a provider
    func availableModels(for provider: LLMProvider) -> [String] {
        guard let config = configuration?.providers[provider.rawValue] else {
            return []
        }
        return Array(config.models.keys)
    }
}