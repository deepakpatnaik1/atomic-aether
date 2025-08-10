//
//  LLMRequest.swift
//  atomic-aether
//
//  Unified request model for LLM services
//
//  ATOM 202: LLM Services - Request model
//
//  Atomic LEGO: Simple data structure for LLM requests
//  Provider-agnostic, contains all common fields
//

import Foundation

struct LLMRequest {
    let messages: [Message]
    let model: String // Format: "provider:model-name"
    let temperature: Double?
    let maxTokens: Int?
    let streamingEnabled: Bool?
    var metadata: [String: Any]?
    var stream: Bool?
    
    struct Message {
        let role: MessageRole
        let content: String
        
        init(role: MessageRole, content: String) {
            self.role = role
            self.content = content
        }
    }
    
    /// Convenience initializer for single user message
    init(userMessage: String, model: String, temperature: Double? = nil, maxTokens: Int? = nil, streamingEnabled: Bool? = nil, metadata: [String: Any]? = nil, stream: Bool? = nil) {
        self.messages = [Message(role: .user, content: userMessage)]
        self.model = model
        self.temperature = temperature
        self.maxTokens = maxTokens
        self.streamingEnabled = streamingEnabled
        self.metadata = metadata
        self.stream = stream
    }
    
    /// Full initializer for conversation history
    init(messages: [Message], model: String, temperature: Double? = nil, maxTokens: Int? = nil, streamingEnabled: Bool? = nil, metadata: [String: Any]? = nil, stream: Bool? = nil) {
        self.messages = messages
        self.model = model
        self.temperature = temperature
        self.maxTokens = maxTokens
        self.streamingEnabled = streamingEnabled
        self.metadata = metadata
        self.stream = stream
    }
}