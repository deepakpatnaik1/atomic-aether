//
//  ModelDisplayConfiguration.swift
//  atomic-aether
//
//  Configuration for model display names
//
//  ATOM 18: Dynamic Model Display - Configuration
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
        switch provider.lowercased() {
        case "anthropic": return "Claude"
        case "openai": return "GPT"
        case "fireworks": return "Fireworks"
        default: return provider.capitalized
        }
    }
    
    /// Format model name
    private func formatModelName(_ modelName: String) -> String {
        // Special cases for known models
        switch modelName {
        case "claude-sonnet-4-20250514": return "Sonnet 4"
        case "claude-opus-4-20250514": return "Opus 4"
        case "gpt-4.1-mini-2025-04-14": return "4.1 mini"
        case "gpt-4o": return "4o"
        case let name where name.contains("llama4-maverick"):
            return "Llama 4 Maverick"
        default:
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
    }
    
    // MARK: - Default Configuration
    
    static let `default` = ModelDisplayConfiguration(
        modelDisplayNames: [
            "anthropic:claude-sonnet-4-20250514": "Claude Sonnet 4",
            "anthropic:claude-opus-4-20250514": "Claude Opus 4",
            "openai:gpt-4.1-mini-2025-04-14": "GPT 4.1 mini",
            "openai:gpt-4o": "GPT 4o",
            "fireworks:accounts/fireworks/models/llama4-maverick-instruct-basic": "Llama 4 Maverick"
        ],
        showProvider: false,
        providerSeparator: " "
    )
}