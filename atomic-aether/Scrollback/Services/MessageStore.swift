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
    
    /// Clear all messages
    func clearMessages() {
        messages.removeAll()
    }
}