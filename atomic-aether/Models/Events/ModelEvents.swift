//
//  ModelEvents.swift
//  atomic-aether
//
//  Events for model registry changes
//
//  ATOM 9: Models - Event definitions
//
//  Atomic LEGO: Events published when models are loaded or validated
//

import Foundation

// MARK: - Model Event Type

protocol ModelEventType: AetherEvent {}

// MARK: - Model Events

struct ModelsLoadedEvent: ModelEventType {
    let providers: [LLMProvider]
    let source: String = "Models"
}

struct ModelValidationFailedEvent: ModelEventType {
    let modelString: String
    let source: String = "Models"
}

// MARK: - Convenience Namespace

enum ModelEvents {
    static func modelsLoaded(providers: [LLMProvider]) -> ModelsLoadedEvent {
        return ModelsLoadedEvent(providers: providers)
    }
    
    static func validationFailed(modelString: String) -> ModelValidationFailedEvent {
        return ModelValidationFailedEvent(modelString: modelString)
    }
}