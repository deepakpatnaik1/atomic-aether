//
//  MessageStore.swift
//  atomic-aether
//
//  Central message storage for scrollback
//
//  ATOM 9: Scrollback Message Area - Message storage
//
//  Atomic LEGO: Simple storage service, no business logic
//  Just holds messages for display
//

import Foundation
import SwiftUI

@MainActor
class MessageStore: ObservableObject {
    @Published private(set) var messages: [Message] = []
    
    /// Add a new message to the store
    func addMessage(_ message: Message) {
        messages.append(message)
    }
    
    /// Update an existing message (for streaming updates)
    func updateMessage(_ message: Message) {
        if let index = messages.firstIndex(where: { $0.id == message.id }) {
            messages[index] = message
        }
    }
    
    /// Update message content and streaming state
    func updateMessage(_ id: UUID, content: String, isStreaming: Bool) {
        if let index = messages.firstIndex(where: { $0.id == id }) {
            var updatedMessage = messages[index]
            updatedMessage.content = content
            updatedMessage.isStreaming = isStreaming
            messages[index] = updatedMessage
        }
    }
    
    /// Get a message by ID
    func message(by id: UUID) -> Message? {
        messages.first(where: { $0.id == id })
    }
    
    /// Clear all messages
    func clearMessages() {
        messages.removeAll()
    }
}