//
//  ModelStateService.swift
//  atomic-aether
//
//  Manages model selection state with defaults and overrides
//
//  ATOM 12: Model State Management - Core Service
//
//  Atomic LEGO: Central service for model state management
//  - Tracks default models for Anthropic/non-Anthropic
//  - Manages user overrides via model picker
//  - Resolves current model based on persona type
//  - Persists selections via StateBus
//

import Foundation
import SwiftUI
import Combine

@MainActor
final class ModelStateService: ObservableObject {
    
    // MARK: - Published Properties
    
    @Published private(set) var currentDefaultAnthropicModel: String
    @Published private(set) var currentDefaultNonAnthropicModel: String
    @Published private(set) var currentAnthropicModel: String?
    @Published private(set) var currentNonAnthropicModel: String?
    
    // MARK: - Dependencies
    
    private let configBus: ConfigBus
    private let stateBus: StateBus
    private let eventBus: EventBus
    private let errorBus: ErrorBus
    private let llmRouter: LLMRouter
    
    private var configuration: ModelStateConfiguration = .default
    
    // MARK: - Computed Properties
    
    /// The currently active model based on persona type
    /// This will be set by PersonaService in ATOM 13
    var currentModel: String {
        // For now, return default Anthropic model
        // ATOM 13 will provide currentPersona logic
        return currentAnthropicModel ?? currentDefaultAnthropicModel
    }
    
    /// Get resolved model for Anthropic personas
    var resolvedAnthropicModel: String {
        currentAnthropicModel ?? currentDefaultAnthropicModel
    }
    
    /// Get resolved model for non-Anthropic personas
    var resolvedNonAnthropicModel: String {
        currentNonAnthropicModel ?? currentDefaultNonAnthropicModel
    }
    
    // MARK: - Initialization
    
    init(
        configBus: ConfigBus,
        stateBus: StateBus,
        eventBus: EventBus,
        errorBus: ErrorBus,
        llmRouter: LLMRouter
    ) {
        self.configBus = configBus
        self.stateBus = stateBus
        self.eventBus = eventBus
        self.errorBus = errorBus
        self.llmRouter = llmRouter
        
        // Initialize with safe defaults - DO NOT load config or set values here
        self.currentDefaultAnthropicModel = "anthropic:claude-sonnet-4-20250514"
        self.currentDefaultNonAnthropicModel = "openai:gpt-4.1-mini-2025-04-14"
    }
    
    // MARK: - Public Methods
    
    /// Setup method to be called after view initialization
    func setup() {
        // Load configuration
        if let loadedConfig = configBus.load("ModelState", as: ModelStateConfiguration.self) {
            self.configuration = loadedConfig
            self.currentDefaultAnthropicModel = loadedConfig.defaultAnthropicModel
            self.currentDefaultNonAnthropicModel = loadedConfig.defaultNonAnthropicModel
        }
        
        // Restore persisted state
        restorePersistedState()
    }
    
    /// Select a model (determines if it's Anthropic or non-Anthropic)
    func selectModel(_ model: String) {
        // Validate model exists
        guard llmRouter.supportsModel(model) else {
            errorBus.report(
                message: "Invalid model: \(model)",
                from: "ModelStateService",
                severity: .warning
            )
            return
        }
        
        // Determine model type and update appropriate override
        if configuration.isAnthropicModel(model) {
            currentAnthropicModel = model
            stateBus.set(.currentAnthropicModel, value: model)
        } else if configuration.isNonAnthropicModel(model) {
            currentNonAnthropicModel = model
            stateBus.set(.currentNonAnthropicModel, value: model)
        } else {
            // Model not in our configuration - add it dynamically
            handleUnknownModel(model)
        }
        
        // Update history
        updateModelHistory(model)
        
        // Publish event
        eventBus.publish(ModelSelectedEvent(model: model))
    }
    
    /// Clear override for Anthropic models
    func clearAnthropicOverride() {
        currentAnthropicModel = nil
        stateBus.set(.currentAnthropicModel, value: "")
        eventBus.publish(ModelOverrideClearedEvent(isAnthropic: true))
    }
    
    /// Clear override for non-Anthropic models
    func clearNonAnthropicOverride() {
        currentNonAnthropicModel = nil
        stateBus.set(.currentNonAnthropicModel, value: "")
        eventBus.publish(ModelOverrideClearedEvent(isAnthropic: false))
    }
    
    /// Update default models (e.g., from configuration change)
    func updateDefaults(anthropic: String? = nil, nonAnthropic: String? = nil) {
        if let anthropic = anthropic {
            currentDefaultAnthropicModel = anthropic
        }
        if let nonAnthropic = nonAnthropic {
            currentDefaultNonAnthropicModel = nonAnthropic
        }
        
        eventBus.publish(ModelDefaultsChangedEvent(
            anthropic: currentDefaultAnthropicModel,
            nonAnthropic: currentDefaultNonAnthropicModel
        ))
    }
    
    /// Check if a model is Anthropic
    func isAnthropicModel(_ model: String) -> Bool {
        configuration.isAnthropicModel(model)
    }
    
    /// Get available models by type
    func availableModels(anthropic: Bool) -> [String] {
        let allModels = llmRouter.availableModels
        
        if anthropic {
            return allModels.filter { configuration.isAnthropicModel($0) }
        } else {
            return allModels.filter { configuration.isNonAnthropicModel($0) }
        }
    }
    
    // MARK: - Private Methods
    
    private func restorePersistedState() {
        // Restore overrides from StateBus
        let storedAnthropic = stateBus.get(.currentAnthropicModel) ?? ""
        self.currentAnthropicModel = storedAnthropic.isEmpty ? nil : storedAnthropic
        
        let storedNonAnthropic = stateBus.get(.currentNonAnthropicModel) ?? ""
        self.currentNonAnthropicModel = storedNonAnthropic.isEmpty ? nil : storedNonAnthropic
        
        // Validate restored models
        validateRestoredModels()
        
        // Note: lastSelectedModel will be used by UI in future atoms
        // For now, we just check if it exists for debugging
        _ = stateBus.get(.lastSelectedModel)
    }
    
    private func validateRestoredModels() {
        // Validate Anthropic override
        if let model = currentAnthropicModel,
           !llmRouter.supportsModel(model) {
            currentAnthropicModel = nil
            stateBus.set(.currentAnthropicModel, value: "")
        }
        
        // Validate non-Anthropic override
        if let model = currentNonAnthropicModel,
           !llmRouter.supportsModel(model) {
            currentNonAnthropicModel = nil
            stateBus.set(.currentNonAnthropicModel, value: "")
        }
    }
    
    private func handleUnknownModel(_ model: String) {
        // Determine type by provider prefix
        if model.hasPrefix("anthropic:") {
            configuration.anthropicModels.append(model)
            currentAnthropicModel = model
            stateBus.set(.currentAnthropicModel, value: model)
        } else {
            configuration.nonAnthropicModels.append(model)
            currentNonAnthropicModel = model
            stateBus.set(.currentNonAnthropicModel, value: model)
        }
    }
    
    private func updateModelHistory(_ model: String) {
        var history = stateBus.get(.modelSelectionHistory) ?? []
        history.append(model)
        
        // Keep only last 50 selections
        if history.count > 50 {
            history = Array(history.suffix(50))
        }
        
        stateBus.set(.modelSelectionHistory, value: history)
        stateBus.set(.lastSelectedModel, value: model)
    }
}