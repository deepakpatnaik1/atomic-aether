//
//  ConversationFlowEvents.swift
//  atomic-aether
//
//  Events specific to the conversation flow orchestration
//
//  ATOM 501: ConversationFlow - Event definitions
//
//  Atomic LEGO: Struct-based events for conversation orchestration
//  Separate from the enum-based ConversationEvents
//

import Foundation

// MARK: - Conversation Flow Events

struct ConversationStartedEvent: AetherEvent, ConversationEventType {
    let sessionId: UUID
    let persona: String
    let model: String
    let source: String = "ConversationOrchestrator"
}

struct ConversationMessageSentEvent: AetherEvent, ConversationEventType {
    let sessionId: UUID
    let messageId: UUID
    let persona: String
    let content: String
    let source: String = "ConversationOrchestrator"
}

struct ConversationResponseReceivedEvent: AetherEvent, ConversationEventType {
    let sessionId: UUID
    let messageId: UUID
    let persona: String
    let model: String
    let source: String = "ConversationOrchestrator"
}

struct ConversationErrorEvent: AetherEvent, ConversationEventType {
    let sessionId: UUID
    let error: String
    let persona: String
    let retryAttempt: Int
    let source: String = "ConversationOrchestrator"
}

struct ConversationIdleEvent: AetherEvent, ConversationEventType {
    let sessionId: UUID
    let idleDuration: TimeInterval
    let source: String = "ConversationOrchestrator"
}

struct ConversationStreamingEvent: AetherEvent, ConversationEventType {
    let messageId: UUID
    let contentLength: Int
    let persona: String
    let source: String = "StreamProcessor"
}

struct ConversationCompletedEvent: AetherEvent, ConversationEventType {
    let messageId: UUID
    let success: Bool
    let contentLength: Int
    let source: String = "StreamProcessor"
}