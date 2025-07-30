//
//  LLMProvider.swift
//  atomic-aether
//
//  Provider enumeration for LLM services
//
//  ATOM 8: LLM Services - Provider identification
//
//  Atomic LEGO: Simple enum to identify LLM providers
//  Used for routing and configuration
//

import Foundation

enum LLMProvider: String, CaseIterable {
    case openai
    case anthropic
    case fireworks
    
    /// Extract provider from model string format "provider:model-name"
    static func from(modelString: String) -> LLMProvider? {
        let components = modelString.split(separator: ":", maxSplits: 1)
        guard let providerString = components.first else { return nil }
        return LLMProvider(rawValue: String(providerString))
    }
    
    /// Extract model name from model string format "provider:model-name"
    static func extractModelName(from modelString: String) -> String {
        let components = modelString.split(separator: ":", maxSplits: 1)
        if components.count == 2 {
            return String(components[1])
        }
        return modelString
    }
}