//
//  LLMResponse.swift
//  atomic-aether
//
//  Response model for streaming LLM responses
//
//  ATOM 18: LLM Services - Response chunks
//
//  Atomic LEGO: Simple data structure for streaming response chunks
//  Supports both content deltas and metadata
//

import Foundation

enum LLMResponse {
    case content(String) // Partial content chunk
    case metadata(LLMMetadata) // Response metadata
    case error(LLMError) // Error during streaming
    case done // Stream completed
}

struct LLMMetadata {
    let model: String?
    let promptTokens: Int?
    let completionTokens: Int?
    let totalTokens: Int?
    let finishReason: String?
}

enum LLMError: Error, LocalizedError {
    case apiKeyMissing
    case invalidModel(String)
    case networkError(String)
    case rateLimitExceeded
    case invalidResponse(String)
    case streamingError(String)
    case providerError(String, String) // provider, message
    
    var errorDescription: String? {
        switch self {
        case .apiKeyMissing:
            return "API key not found in environment"
        case .invalidModel(let model):
            return "Invalid model: \(model)"
        case .networkError(let message):
            return "Network error: \(message)"
        case .rateLimitExceeded:
            return "Rate limit exceeded"
        case .invalidResponse(let message):
            return "Invalid response: \(message)"
        case .streamingError(let message):
            return "Streaming error: \(message)"
        case .providerError(let provider, let message):
            return "\(provider) error: \(message)"
        }
    }
}