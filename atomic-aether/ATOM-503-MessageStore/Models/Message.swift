//
//  Message.swift
//  atomic-aether
//
//  Chat message model
//
//  ATOM 503: Message Store - Core message model
//
//  Atomic LEGO: Simple value type for message data
//  No business logic, just data storage
//

import Foundation

struct Message: Identifiable, Equatable, Codable {
    let id: UUID
    let speaker: String        // Persona ID from configuration
    var content: String
    let timestamp: Date
    var isStreaming: Bool
    let modelUsed: String?     // Which LLM model was used
    
    init(
        id: UUID = UUID(),
        speaker: String,
        content: String,
        timestamp: Date = Date(),
        isStreaming: Bool = false,
        modelUsed: String? = nil
    ) {
        self.id = id
        self.speaker = speaker
        self.content = content
        self.timestamp = timestamp
        self.isStreaming = isStreaming
        self.modelUsed = modelUsed
    }
}