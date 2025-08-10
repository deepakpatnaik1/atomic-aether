//
//  ModelDisplayConfiguration.swift
//  atomic-aether
//
//  Configuration for model display names
//
//  ATOM 203: Model Display - Configuration
//
//  Atomic LEGO: Configuration structure for model display
//  Loaded from ModelDisplay.json via ConfigBus
//

import Foundation

struct ModelDisplayConfiguration: Codable {
    // Display name mappings for models
    let modelDisplayNames: [String: String]
    
    // Display format options
    let showProvider: Bool
    let providerSeparator: String
    
    // Provider display names
    let providerDisplayNames: [String: String]
    
    // Model short names
    let modelShortNames: [String: String]
    
    // Model pattern replacements
    let modelPatternReplacements: [String: String]
    
    // MARK: - Helper Methods
    
    /// Get display name for a model ID
    func displayName(for modelId: String) -> String {
        // Check for custom display name
        if let customName = modelDisplayNames[modelId] {
            return customName
        }
        
        // Extract provider and model name
        let components = modelId.split(separator: ":")
        guard components.count == 2 else {
            return modelId // Return as-is if not in expected format
        }
        
        let provider = String(components[0])
        let modelName = String(components[1])
        
        // Format the display name
        if showProvider {
            return "\(formatProvider(provider))\(providerSeparator)\(formatModelName(modelName))"
        } else {
            return formatModelName(modelName)
        }
    }
    
    /// Format provider name
    private func formatProvider(_ provider: String) -> String {
        // Check configuration first
        if let displayName = providerDisplayNames[provider.lowercased()] {
            return displayName
        }
        // Default to capitalized
        return provider.capitalized
    }
    
    /// Format model name
    private func formatModelName(_ modelName: String) -> String {
        // Check for exact short names first
        if let shortName = modelShortNames[modelName] {
            return shortName
        }
        
        // Check for pattern replacements
        for (pattern, replacement) in modelPatternReplacements {
            if modelName.contains(pattern) {
                return replacement
            }
        }
        
        // Generic formatting: Remove dates, capitalize
        let cleanName = modelName
            .replacingOccurrences(of: "-20[0-9]{6}", with: "", options: .regularExpression)
            .replacingOccurrences(of: "_", with: " ")
            .replacingOccurrences(of: "-", with: " ")
        
        return cleanName
            .split(separator: " ")
            .map { $0.capitalized }
            .joined(separator: " ")
    }
    
    // MARK: - Default Configuration
    
    static let `default` = ModelDisplayConfiguration(
        modelDisplayNames: [:],
        showProvider: false,
        providerSeparator: " ",
        providerDisplayNames: [:],
        modelShortNames: [:],
        modelPatternReplacements: [:]
    )
}