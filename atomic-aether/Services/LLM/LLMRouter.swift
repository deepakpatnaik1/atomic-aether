//
//  LLMRouter.swift
//  atomic-aether
//
//  Routes LLM requests to appropriate service
//
//  ATOM 8: LLM Services - Request router
//
//  Atomic LEGO: Central router that directs requests to correct provider
//  Uses provider prefix to determine routing
//

import Foundation
import SwiftUI

@MainActor
class LLMRouter: ObservableObject, LLMService {
    @Published var isConfigured = false
    @Published var availableModels: [String] = []
    
    private var services: [LLMProvider: LLMService] = [:]
    private var configuration: LLMConfiguration?
    private let envLoader: EnvLoader
    private let configBus: ConfigBus
    private let eventBus: EventBus
    
    init(envLoader: EnvLoader, configBus: ConfigBus, eventBus: EventBus) {
        self.envLoader = envLoader
        self.configBus = configBus
        self.eventBus = eventBus
        
        setupServices()
    }
    
    func setupServices() {
        // Load configuration
        guard let config = configBus.load("LLMProviders", as: LLMConfiguration.self) else {
            print("❌ Failed to load LLM configuration")
            return
        }
        
        self.configuration = config
        
        // Get API keys
        guard let environment = envLoader.environment else {
            print("❌ Environment not loaded")
            return
        }
        
        // Setup OpenAI service
        if let openAIKey = environment.openAIKey,
           let openAIConfig = config.providers["openai"] {
            services[.openai] = OpenAIService(
                config: openAIConfig,
                apiKey: openAIKey,
                eventBus: eventBus
            )
            
            // Add OpenAI models to available models
            for modelKey in openAIConfig.models.keys {
                availableModels.append("openai:\(modelKey)")
            }
        }
        
        // Setup Anthropic service
        if let anthropicKey = environment.anthropicKey,
           let anthropicConfig = config.providers["anthropic"] {
            services[.anthropic] = AnthropicService(
                config: anthropicConfig,
                apiKey: anthropicKey,
                eventBus: eventBus
            )
            
            // Add Anthropic models to available models
            for modelKey in anthropicConfig.models.keys {
                availableModels.append("anthropic:\(modelKey)")
            }
        }
        
        // Setup Fireworks service
        if let fireworksKey = environment.fireworksKey,
           let fireworksConfig = config.providers["fireworks"] {
            services[.fireworks] = FireworksService(
                config: fireworksConfig,
                apiKey: fireworksKey,
                eventBus: eventBus
            )
            
            // Add Fireworks models to available models
            for modelKey in fireworksConfig.models.keys {
                availableModels.append("fireworks:\(modelKey)")
            }
        }
        
        isConfigured = !services.isEmpty
        
        if isConfigured {
            print("✅ LLM Router configured with providers: \(services.keys.map { $0.rawValue })")
            print("📋 Available models: \(availableModels)")
        } else {
            print("❌ No LLM services configured - check API keys")
        }
    }
    
    func supportsModel(_ model: String) -> Bool {
        guard let provider = LLMProvider.from(modelString: model),
              let service = services[provider] else {
            return false
        }
        return service.supportsModel(model)
    }
    
    func sendMessage(_ request: LLMRequest) async throws -> AsyncThrowingStream<LLMResponse, Error> {
        guard let provider = LLMProvider.from(modelString: request.model) else {
            throw LLMError.invalidModel("Invalid model format: \(request.model)")
        }
        
        guard let service = services[provider] else {
            throw LLMError.apiKeyMissing
        }
        
        return try await service.sendMessage(request)
    }
    
    /// Get the default model from configuration
    var defaultModel: String? {
        configuration?.defaultModel
    }
    
    /// Check if streaming is enabled by default
    var defaultStreamingEnabled: Bool {
        configuration?.defaultStreamingEnabled ?? true
    }
}