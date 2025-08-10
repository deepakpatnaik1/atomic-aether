//
//  LLMConfiguration.swift
//  atomic-aether
//
//  Configuration models for LLM providers
//
//  ATOM 202: LLM Services - Configuration structures
//
//  Atomic LEGO: Data models matching LLMProviders.json structure
//  Codable for easy JSON loading via ConfigBus
//

import Foundation

struct LLMConfiguration: Codable {
    let providers: [String: ProviderConfig]
    let defaultModel: String
    let defaultStreamingEnabled: Bool
}

struct ProviderConfig: Codable {
    let name: String
    let baseURL: String
    let endpoint: String
    let authHeader: String
    let authPrefix: String
    let streamingEnabled: Bool
    let additionalHeaders: [String: String]?
    let models: [String: ModelConfig]
    
    // Structured output support (Phase II)
    let supportsStructuredOutput: Bool?
    let structuredOutputMethod: String?
}

struct ModelConfig: Codable {
    let displayName: String
    let maxTokens: Int
}