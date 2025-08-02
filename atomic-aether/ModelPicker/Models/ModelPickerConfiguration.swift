//
//  ModelPickerConfiguration.swift
//  atomic-aether
//
//  Configuration for model picker UI
//
//  ATOM 19: Interactive Model Picker - Configuration
//
//  Atomic LEGO: Configuration structure for model picker
//  Loaded from ModelPicker.json via ConfigBus
//

import Foundation

struct ModelPickerConfiguration: Codable {
    // Display options
    let groupByProvider: Bool
    let showProviderHeaders: Bool
    let showCheckmark: Bool
    
    // Provider display settings
    let providerIcons: [String: String]
    let providerOrder: [String]
    
    // Interaction settings
    let allowDynamicModels: Bool
    
    // MARK: - Helper Methods
    
    /// Get icon for provider
    func icon(for provider: String) -> String {
        providerIcons[provider.lowercased()] ?? "cpu"
    }
    
    /// Sort providers according to configured order
    func sortedProviders(from providers: [String]) -> [String] {
        // First, include providers in the configured order
        let orderedProviders = providerOrder.filter { providers.contains($0) }
        
        // Then, append any remaining providers not in the configured order
        let remainingProviders = providers.filter { !providerOrder.contains($0) }
        
        return orderedProviders + remainingProviders.sorted()
    }
    
    // MARK: - Default Configuration
    
    static let `default` = ModelPickerConfiguration(
        groupByProvider: true,
        showProviderHeaders: true,
        showCheckmark: true,
        providerIcons: [
            "anthropic": "brain.head.profile",
            "openai": "cpu",
            "fireworks": "flame",
            "groq": "bolt",
            "cohere": "text.bubble",
            "mistral": "wind"
        ],
        providerOrder: ["anthropic", "openai", "fireworks"],
        allowDynamicModels: false
    )
}