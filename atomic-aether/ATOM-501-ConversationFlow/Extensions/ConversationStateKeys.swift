//
//  ConversationStateKeys.swift
//  atomic-aether
//
//  State keys for conversation flow
//
//  ATOM 501: ConversationFlow - StateBus keys
//
//  Atomic LEGO: Type-safe keys for conversation state
//  Enables persistence and restoration of conversation context
//

import Foundation

// MARK: - Conversation State Keys

extension StateKey where T == ConversationContext {
    static let currentConversationContext = StateKey<ConversationContext>("conversation.currentContext")
}

extension StateKey where T == Date {
    static let lastConversationActivity = StateKey<Date>("conversation.lastActivity")
}