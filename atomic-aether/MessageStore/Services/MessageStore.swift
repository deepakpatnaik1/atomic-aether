//
//  MessageStore.swift
//  atomic-aether
//
//  Central message storage and management
//
//  ATOM 21: Message Store - Core storage service
//
//  Atomic LEGO: Message persistence and management
//  Configurable limits and event publishing
//

import Foundation
import SwiftUI

@MainActor
class MessageStore: ObservableObject {
    @Published private(set) var messages: [Message] = []
    
    private var configuration: MessageStoreConfiguration = .default
    private var configBus: ConfigBus?
    private var eventBus: EventBus?
    
    /// Setup with ConfigBus and EventBus
    func setup(configBus: ConfigBus, eventBus: EventBus) {
        self.configBus = configBus
        self.eventBus = eventBus
        
        // Load configuration
        if let config = configBus.load("MessageStore", as: MessageStoreConfiguration.self) {
            self.configuration = config
        }
    }
    
    /// Add a new message to the store
    func addMessage(_ message: Message) {
        messages.append(message)
        
        // Enforce max message limit
        if messages.count > configuration.maxMessages {
            messages.removeFirst(messages.count - configuration.maxMessages)
        }
        
        // Publish event if enabled
        if configuration.publishEvents {
            eventBus?.publish(MessageAddedEvent(message: message))
        }
    }
    
    /// Update an existing message (for streaming updates)
    func updateMessage(_ message: Message) {
        if let index = messages.firstIndex(where: { $0.id == message.id }) {
            messages[index] = message
            
            // Publish event if enabled
            if configuration.publishEvents {
                eventBus?.publish(MessageUpdatedEvent(message: message))
            }
        }
    }
    
    /// Update message content and streaming state
    func updateMessage(_ id: UUID, content: String, isStreaming: Bool) {
        if let index = messages.firstIndex(where: { $0.id == id }) {
            var updatedMessage = messages[index]
            updatedMessage.content = content
            updatedMessage.isStreaming = isStreaming
            messages[index] = updatedMessage
            
            // Publish event if enabled
            if configuration.publishEvents {
                eventBus?.publish(MessageUpdatedEvent(message: updatedMessage))
            }
        }
    }
    
    /// Get a message by ID
    func message(by id: UUID) -> Message? {
        messages.first(where: { $0.id == id })
    }
    
    /// Clear all messages
    func clearMessages() {
        messages.removeAll()
        
        // Publish event if enabled
        if configuration.publishEvents {
            eventBus?.publish(MessagesCleared())
        }
    }
    
    /// Prepend historical messages (Phase II - for ScrollbackHistory)
    func prependHistoricalMessages(_ historicalMessages: [Message]) async {
        guard !historicalMessages.isEmpty else { return }
        
        // Filter out any duplicates based on ID
        let existingIds = Set(messages.map { $0.id })
        let newMessages = historicalMessages.filter { !existingIds.contains($0.id) }
        
        // Prepend to beginning of array
        messages = newMessages + messages
        
        // Still enforce max limit even with historical messages
        if messages.count > configuration.maxMessages {
            messages = Array(messages.suffix(configuration.maxMessages))
        }
        
        // Publish event for historical load
        if configuration.publishEvents {
            eventBus?.publish(HistoricalMessagesLoadedEvent(count: newMessages.count))
        }
    }
}