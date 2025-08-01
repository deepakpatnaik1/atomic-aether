//
//  ModelStateConfiguration.swift
//  atomic-aether
//
//  Configuration for model state defaults
//
//  ATOM 12: Model State Management - Configuration
//
//  Atomic LEGO: Configuration structure for model defaults
//  Loaded from ModelState.json via ConfigBus
//

import Foundation

struct ModelStateConfiguration: Codable {
    let defaultAnthropicModel: String
    let defaultNonAnthropicModel: String
    var anthropicModels: [String]
    var nonAnthropicModels: [String]
    
    // MARK: - Default Configuration
    
    static let `default` = ModelStateConfiguration(
        defaultAnthropicModel: "anthropic:claude-sonnet-4-20250514",
        defaultNonAnthropicModel: "openai:gpt-4.1-mini-2025-04-14",
        anthropicModels: [
            "anthropic:claude-sonnet-4-20250514",
            "anthropic:claude-opus-4-20250514"
        ],
        nonAnthropicModels: [
            "openai:gpt-4.1-mini-2025-04-14",
            "openai:gpt-4o",
            "fireworks:accounts/fireworks/models/llama4-maverick-instruct-basic"
        ]
    )
    
    // MARK: - Helper Methods
    
    func isAnthropicModel(_ model: String) -> Bool {
        anthropicModels.contains(model)
    }
    
    func isNonAnthropicModel(_ model: String) -> Bool {
        nonAnthropicModels.contains(model)
    }
    
    func isValidModel(_ model: String) -> Bool {
        isAnthropicModel(model) || isNonAnthropicModel(model)
    }
}