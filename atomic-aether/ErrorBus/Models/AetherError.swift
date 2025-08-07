//
//  AetherError.swift
//  atomic-aether
//
//  Common error types for the application
//
//  ATOM 2: ErrorBus - Application error types
//
//  Atomic LEGO: Centralized error definitions
//  All atoms can use these common error types
//

import Foundation

enum AetherError: LocalizedError {
    // Network errors
    case networkUnavailable
    case networkTimeout(seconds: Int)
    case apiError(statusCode: Int, message: String)
    
    // LLM errors
    case llmProviderError(provider: String, message: String)
    case llmRateLimited(provider: String, retryAfter: TimeInterval?)
    case llmTokenLimitExceeded(limit: Int)
    case modelNotAvailable(model: String)
    case invalidApiKey(provider: String)
    
    // Persona errors
    case personaNotFound(name: String)
    case personaIncompatible(persona: String, model: String)
    
    // Configuration errors
    case configurationMissing(file: String)
    case configurationInvalid(file: String, reason: String)
    
    // State errors
    case stateNotFound(key: String)
    case stateTypeMismatch(key: String, expected: String, actual: String)
    
    // User errors
    case validationError(field: String, reason: String)
    case emptyInput
    
    // MARK: - LocalizedError
    
    var errorDescription: String? {
        switch self {
        case .networkUnavailable:
            return "Network connection unavailable"
        case .networkTimeout(let seconds):
            return "Network request timed out after \(seconds) seconds"
        case .apiError(let code, let message):
            return "API Error (\(code)): \(message)"
            
        case .llmProviderError(let provider, let message):
            return "\(provider): \(message)"
        case .llmRateLimited(let provider, let retryAfter):
            if let retry = retryAfter {
                return "\(provider) rate limit exceeded. Retry after \(Int(retry)) seconds"
            }
            return "\(provider) rate limit exceeded"
        case .llmTokenLimitExceeded(let limit):
            return "Token limit exceeded (\(limit) tokens)"
        case .modelNotAvailable(let model):
            return "Model '\(model)' is not available"
        case .invalidApiKey(let provider):
            return "Invalid API key for \(provider)"
            
        case .personaNotFound(let name):
            return "Persona '\(name)' not found"
        case .personaIncompatible(let persona, let model):
            return "Persona '\(persona)' is not compatible with model '\(model)'"
            
        case .configurationMissing(let file):
            return "Configuration file '\(file)' not found"
        case .configurationInvalid(let file, let reason):
            return "Invalid configuration in '\(file)': \(reason)"
            
        case .stateNotFound(let key):
            return "State key '\(key)' not found"
        case .stateTypeMismatch(let key, let expected, let actual):
            return "State key '\(key)' type mismatch: expected \(expected), got \(actual)"
            
        case .validationError(let field, let reason):
            return "\(field): \(reason)"
        case .emptyInput:
            return "Input cannot be empty"
        }
    }
    
    var recoverySuggestion: String? {
        switch self {
        case .networkUnavailable:
            return "Check your internet connection"
        case .networkTimeout:
            return "Try again or check your connection"
        case .apiError:
            return "Try again later"
            
        case .llmProviderError:
            return "Try a different model or provider"
        case .llmRateLimited:
            return "Wait a moment before trying again"
        case .llmTokenLimitExceeded:
            return "Try a shorter message"
        case .modelNotAvailable:
            return "Select a different model"
        case .invalidApiKey(let provider):
            return "Check your \(provider) API key in settings"
            
        case .personaNotFound:
            return "Check available personas"
        case .personaIncompatible:
            return "Use a compatible model for this persona"
            
        case .configurationMissing, .configurationInvalid:
            return "Check application configuration"
            
        case .stateNotFound, .stateTypeMismatch:
            return "Restart the application"
            
        case .validationError, .emptyInput:
            return "Check your input and try again"
        }
    }
}