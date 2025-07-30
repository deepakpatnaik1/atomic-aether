//
//  LLMService.swift
//  atomic-aether
//
//  Protocol for LLM service implementations
//
//  ATOM 8: LLM Services - Service protocol
//
//  Atomic LEGO: Unified interface for all LLM providers
//  Each provider implements this protocol differently
//

import Foundation

@MainActor
protocol LLMService {
    /// Send a message to the LLM and receive streaming response
    func sendMessage(_ request: LLMRequest) async throws -> AsyncThrowingStream<LLMResponse, Error>
    
    /// Check if the service supports a given model
    func supportsModel(_ model: String) -> Bool
}