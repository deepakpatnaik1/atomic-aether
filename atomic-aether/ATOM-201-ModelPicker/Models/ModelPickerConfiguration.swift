//
//  ModelPickerConfiguration.swift
//  atomic-aether
//
//  Configuration for model picker UI
//
//  ATOM 201: Model Picker - Configuration
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
    let autoSwitchPersona: Bool
    
    // UI settings
    let chevronSizeRatio: Double
    
    // Default labels
    let allModelsLabel: String
    let unknownProviderLabel: String
    let providerSeparator: String
    
    // Typography settings
    let typography: Typography?
    let menuItemLayout: MenuItemLayout?
    
    // MARK: - Nested Types
    
    struct Typography: Codable {
        let sectionHeader: SectionHeaderConfig?
        
        struct SectionHeaderConfig: Codable {
            let sizeMultiplier: Double
            let opacityMultiplier: Double
        }
    }
    
    struct MenuItemLayout: Codable {
        let checkmarkIcon: String
    }
    
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
        allowDynamicModels: false,
        autoSwitchPersona: true,
        chevronSizeRatio: 0.7,
        allModelsLabel: "All Models",
        unknownProviderLabel: "unknown",
        providerSeparator: ":",
        typography: nil,
        menuItemLayout: nil
    )
}