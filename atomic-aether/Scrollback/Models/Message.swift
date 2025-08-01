//
//  Message.swift
//  atomic-aether
//
//  Chat message model for scrollback display
//
//  ATOM 9: Scrollback Message Area - Core message model
//
//  Atomic LEGO: Simple value type for message data
//  No business logic, just data storage
//

import Foundation

struct Message: Identifiable, Equatable {
    let id = UUID()
    let speaker: String        // "boss" or "system" (will map to personas)
    var content: String
    let timestamp: Date
    var isStreaming: Bool
    let modelUsed: String?     // Which LLM model was used (e.g., "openai:gpt-4o")
    
    init(
        speaker: String,
        content: String,
        timestamp: Date = Date(),
        isStreaming: Bool = false,
        modelUsed: String? = nil
    ) {
        self.speaker = speaker
        self.content = content
        self.timestamp = timestamp
        self.isStreaming = isStreaming
        self.modelUsed = modelUsed
    }
}