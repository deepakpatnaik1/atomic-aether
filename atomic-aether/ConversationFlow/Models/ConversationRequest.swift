//
//  ConversationRequest.swift
//  atomic-aether
//
//  Request model for conversation flow
//
//  ATOM 15: Conversation Flow - Request model
//
//  Atomic LEGO: Data structure for LLM requests
//  Includes persona context and conversation history
//

import Foundation

// Use typealias to disambiguate Message types
typealias ChatMessage = Message

struct ConversationRequest {
    let userMessage: String
    let persona: String
    let systemPrompt: String
    let model: String
    let conversationHistory: [ChatMessage]
    let maxTokens: Int?
    let temperature: Double?
    let streamingEnabled: Bool
    
    /// Build LLMRequest for router
    func toLLMRequest() -> LLMRequest {
        var messages: [LLMRequest.Message] = []
        
        // Add system prompt
        if !systemPrompt.isEmpty {
            messages.append(LLMRequest.Message(
                role: .system,
                content: systemPrompt
            ))
        }
        
        // Add conversation history
        for message in conversationHistory {
            let role: MessageRole = message.speaker == persona ? .assistant : .user
            messages.append(LLMRequest.Message(
                role: role,
                content: message.content
            ))
        }
        
        // Add current user message
        messages.append(LLMRequest.Message(
            role: .user,
            content: userMessage
        ))
        
        return LLMRequest(
            messages: messages,
            model: model,
            temperature: temperature,
            maxTokens: maxTokens,
            streamingEnabled: streamingEnabled
        )
    }
}