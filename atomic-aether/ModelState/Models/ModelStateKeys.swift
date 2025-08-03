//
//  ModelStateKeys.swift
//  atomic-aether
//
//  StateKey definitions for model state
//
//  ATOM 17: Model State - State Keys
//
//  Atomic LEGO: Type-safe keys for StateBus storage
//  Enables persistence of model selections
//

import Foundation

// MARK: - Model State Keys

extension StateKey {
    /// Current override for Anthropic model (empty = use default)
    static var currentAnthropicModel: StateKey<String> {
        StateKey<String>("modelState.currentAnthropicModel")
    }
    
    /// Current override for non-Anthropic model (empty = use default)
    static var currentNonAnthropicModel: StateKey<String> {
        StateKey<String>("modelState.currentNonAnthropicModel")
    }
    
    /// Last selected model (for UI persistence)
    static var lastSelectedModel: StateKey<String> {
        StateKey<String>("modelState.lastSelectedModel")
    }
    
    /// Model selection history (for debugging/analytics)
    static var modelSelectionHistory: StateKey<[String]> {
        StateKey<[String]>("modelState.selectionHistory")
    }
}

// MARK: - Model Events

struct ModelSelectedEvent: AetherEvent, SystemEventType {
    let model: String
    let source: String
    
    init(model: String, source: String = "ModelStateService") {
        self.model = model
        self.source = source
    }
}

struct ModelDefaultsChangedEvent: AetherEvent, SystemEventType {
    let anthropicDefault: String
    let nonAnthropicDefault: String
    let source: String
    
    init(anthropic: String, nonAnthropic: String, source: String = "ModelStateService") {
        self.anthropicDefault = anthropic
        self.nonAnthropicDefault = nonAnthropic
        self.source = source
    }
}

struct ModelOverrideClearedEvent: AetherEvent, SystemEventType {
    let isAnthropic: Bool
    let source: String
    
    init(isAnthropic: Bool, source: String = "ModelStateService") {
        self.isAnthropic = isAnthropic
        self.source = source
    }
}