//
//  MessageStore.swift
//  atomic-aether
//
//  Central message storage and management
//
//  ATOM 503: Message Store - Core storage service
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
        
        // Load persisted messages if enabled
        if configuration.persistMessages && configuration.loadMessagesOnStartup {
            // Delay message loading to ensure personas are loaded first
            // This prevents the race condition where messages display before personas are ready
            Task { @MainActor in
                try? await Task.sleep(nanoseconds: 200_000_000) // 0.2 seconds
                loadMessagesFromFile()
            }
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
        
        // Save to file if persistence is enabled
        saveMessagesToFile()
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
            
            // Save to file only when streaming completes
            if !isStreaming {
                saveMessagesToFile()
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
    
    /// Prepend historical messages
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
    
    // MARK: - Persistence Methods
    
    /// Save messages to file
    private func saveMessagesToFile() {
        guard configuration.persistMessages,
              let fileName = configuration.persistenceFileName else { return }
        
        do {
            // Get documents directory
            let documentsPath = FileManager.default.urls(for: .documentDirectory, 
                                                       in: .userDomainMask).first!
            let fileURL = documentsPath.appendingPathComponent(fileName)
            
            // Encode messages to JSON
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
            
            let data = try encoder.encode(messages)
            try data.write(to: fileURL)
            
            if configuration.publishEvents {
                eventBus?.publish(MessagesPersisted(count: messages.count))
            }
        } catch {
            // Report error via ErrorBus if available
            print("Failed to save messages: \(error)")
        }
    }
    
    /// Load messages from file
    private func loadMessagesFromFile() {
        guard configuration.persistMessages,
              let fileName = configuration.persistenceFileName else { return }
        
        do {
            // Get documents directory
            let documentsPath = FileManager.default.urls(for: .documentDirectory,
                                                       in: .userDomainMask).first!
            let fileURL = documentsPath.appendingPathComponent(fileName)
            
            // Check if file exists
            guard FileManager.default.fileExists(atPath: fileURL.path) else {
                print("No persisted messages found")
                return
            }
            
            // Decode messages from JSON
            let data = try Data(contentsOf: fileURL)
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            
            let loadedMessages = try decoder.decode([Message].self, from: data)
            
            // Replace messages array
            self.messages = loadedMessages
            
            // Enforce max limit
            if messages.count > configuration.maxMessages {
                messages = Array(messages.suffix(configuration.maxMessages))
            }
            
            if configuration.publishEvents {
                eventBus?.publish(MessagesLoaded(count: messages.count))
            }
        } catch {
            // Report error via ErrorBus if available
            print("Failed to load messages: \(error)")
        }
    }
}