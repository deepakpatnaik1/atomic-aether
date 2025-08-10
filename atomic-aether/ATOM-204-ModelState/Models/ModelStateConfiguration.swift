//
//  ModelStateConfiguration.swift
//  atomic-aether
//
//  Configuration for model state defaults
//
//  ATOM 204: Model State - Configuration
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
    let maxHistorySize: Int
    let anthropicProviderPrefix: String
    let debugView: DebugViewConfiguration
    
    struct DebugViewConfiguration: Codable {
        let width: Double
        let height: Double
    }
    
    // MARK: - Default Configuration
    
    static let `default` = ModelStateConfiguration(
        defaultAnthropicModel: "",
        defaultNonAnthropicModel: "",
        anthropicModels: [],
        nonAnthropicModels: [],
        maxHistorySize: 50,
        anthropicProviderPrefix: "anthropic:",
        debugView: DebugViewConfiguration(width: 400, height: 600)
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