//
//  MessageStoreWire.swift
//  atomic-aether
//
//  Integration documentation for Message Store
//
//  ATOM 503: Message Store - Removal and integration instructions
//

/*
 REMOVAL INSTRUCTIONS:
 To remove Message Store completely:
 1. Delete ATOM-503-MessageStore folder
 2. Remove messageStore initialization from atomic_aetherApp.swift (line ~123)
 3. Remove messageStore environment object from atomic_aetherApp.swift (line ~191)
 4. Remove messageStore from ConversationOrchestrator dependencies (line ~146)
 5. Remove messageStore from StreamProcessor initialization (line ~66)
 6. Remove messageStore from ScrollbackView environment (breaks display)
 
 WARNING: Without MessageStore, no messages can be stored or displayed.
 The app will compile but conversations won't work.
 
 INTEGRATION POINTS:
 - ConversationOrchestrator: Adds user and AI messages
 - StreamProcessor: Updates streaming messages in real-time
 - ScrollbackView: Observes and displays all messages
 - ConfigBus: Loads MessageStore.json configuration
 - EventBus: Publishes message lifecycle events
 
 ARCHITECTURE:
 MessageStore is the single source of truth for all messages:
 1. Maintains @Published array of Message objects
 2. Provides CRUD operations for messages
 3. Enforces message limits to prevent memory issues
 4. Publishes events for message operations
 5. Handles streaming message updates
 
 DATA MODEL:
 ```swift
 struct Message: Identifiable {
     let id = UUID()
     let speaker: String      // "Boss", "Claude", etc.
     var content: String      // Mutable for streaming
     let timestamp = Date()
     var isStreaming: Bool    // Shows progress indicator
     let modelUsed: String?   // Track which model generated
 }
 ```
 
 CONFIGURATION (MessageStore.json):
 ```json
 {
   "maxMessages": 1000,
   "enableEvents": true,
   "trimStrategy": "removeOldest",
   "persistence": {
     "enabled": false,
     "path": null
   }
 }
 ```
 
 MESSAGE LIFECYCLE:
 ```
 User types message
        ↓
 ConversationOrchestrator.processMessage()
        ↓
 messageStore.addMessage(userMessage)
        ↓
 EventBus.publish(MessageAddedEvent)
        ↓
 ScrollbackView updates
        ↓
 AI response starts streaming
        ↓
 messageStore.addMessage(aiMessage, isStreaming: true)
        ↓
 StreamProcessor.updateMessage(id, content: accumulated)
        ↓
 messageStore.updateMessage(id, isStreaming: false)
        ↓
 EventBus.publish(MessageUpdatedEvent)
 ```
 
 API METHODS:
 ```swift
 // Add new message
 func addMessage(_ message: Message)
 
 // Update existing (for streaming)
 func updateMessage(_ id: UUID, content: String, isStreaming: Bool)
 
 // Delete message
 func deleteMessage(_ id: UUID)
 
 // Clear all messages
 func clearAllMessages()
 
 // Get message by ID
 func message(withId id: UUID) -> Message?
 ```
 
 STREAMING SUPPORT:
 ```swift
 // Add placeholder for AI response
 let message = Message(
     speaker: "Claude",
     content: "",
     isStreaming: true
 )
 messageStore.addMessage(message)
 
 // Update as chunks arrive
 messageStore.updateMessage(
     message.id,
     content: accumulated,
     isStreaming: true
 )
 
 // Finalize when complete
 messageStore.updateMessage(
     message.id,
     content: fullResponse,
     isStreaming: false
 )
 ```
 
 MESSAGE LIMITS:
 - Configurable max messages (default: 1000)
 - Automatic trimming of oldest messages
 - Prevents unbounded memory growth
 - Events notify when messages removed
 
 EVENTS PUBLISHED:
 - MessageAddedEvent(message)
 - MessageUpdatedEvent(id, content)
 - MessageDeletedEvent(id)
 - MessagesCleared()
 - MessageLimitReached(removedCount)
 
 BEST PRACTICES:
 - Always check message exists before updating
 - Handle streaming states properly
 - Monitor message count for performance
 - Use events for side effects
 - Don't store sensitive data in messages
 */