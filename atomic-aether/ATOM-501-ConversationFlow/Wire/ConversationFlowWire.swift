//
//  ConversationFlowWire.swift
//  atomic-aether
//
//  Integration documentation for ConversationFlow
//
//  ATOM 501: ConversationFlow - Removal and integration instructions
//

/*
 REMOVAL INSTRUCTIONS:
 To remove ConversationFlow completely:
 1. Delete ATOM-501-ConversationFlow folder
 2. Remove conversationOrchestrator initialization from atomic_aetherApp.swift (line ~141)
 3. Remove conversationOrchestrator environment object from atomic_aetherApp.swift (line ~195)
 4. Remove conversationOrchestrator.setup() call from atomic_aetherApp.swift (line ~212)
 5. Remove processMessage dependency from InputBarView.swift (line ~124)
 6. Replace with simple message adding to MessageStore
 
 WARNING: Without ConversationFlow, no LLM integration will work.
 Messages will just be stored locally without responses.
 
 INTEGRATION POINTS:
 - atomic_aetherApp.swift: Creates and injects ConversationOrchestrator
 - InputBarView: Calls processMessage() on submit
 - PersonaStateService: Provides persona and model selection
 - LLMRouter: Routes requests to appropriate provider
 - MessageStore: Stores conversation messages
 - ConfigBus: Loads ConversationFlow.json configuration
 - EventBus: Publishes conversation lifecycle events
 - ErrorBus: Reports errors during processing
 
 ARCHITECTURE:
 ConversationOrchestrator coordinates the entire flow:
 1. Receives user message from InputBarView
 2. Detects persona via PersonaStateService
 3. Creates conversation context
 4. Adds user message to MessageStore
 5. Builds LLM request with history
 6. Routes to LLM provider via LLMRouter
 7. Handles streaming via StreamProcessor
 8. Updates MessageStore with response
 9. Publishes events throughout lifecycle
 
 CONFIGURATION (ConversationFlow.json):
 ```json
 {
   "userSpeakerName": "Boss",
   "maxContextMessages": 20,
   "streamingEnabled": true,
   "sessionActiveTimeoutSeconds": 3600
 }
 ```
 
 STREAM PROCESSING:
 StreamProcessor handles real-time updates:
 - Accumulates content chunks
 - Updates message during streaming
 - Publishes periodic progress events
 - Handles errors gracefully
 - Finalizes message on completion
 
 CONVERSATION CONTEXT:
 ```swift
 struct ConversationContext {
     let sessionId: UUID
     let currentPersona: String
     let currentModel: String
     var lastActivity: Date
 }
 ```
 
 EVENTS PUBLISHED:
 - ConversationStartedEvent(sessionId, persona, model)
 - ConversationMessageSentEvent(sessionId, messageId, persona, content)
 - ConversationStreamingEvent(messageId, contentLength, persona)
 - ConversationResponseReceivedEvent(sessionId, messageId, persona, model)
 - ConversationCompletedEvent(messageId, success, contentLength)
 - ConversationErrorEvent(sessionId, error, persona, retryAttempt)
 
 REQUEST FLOW:
 ```swift
 await conversationOrchestrator.processMessage(text)
 // 1. Persona detection
 // 2. Context management
 // 3. Message storage
 // 4. LLM request
 // 5. Stream handling
 // 6. Event publishing
 ```
 
 ERROR HANDLING:
 - API key missing → Clear user message
 - Network errors → Descriptive error in message
 - Rate limits → Retry guidance
 - Invalid models → Model name in error
 - Stream errors → Graceful fallback
 
 BEST PRACTICES:
 - Check isProcessing before new requests
 - Maintain reasonable context window
 - Handle streaming gracefully
 - Report all errors to ErrorBus
 - Publish events for monitoring
 - Clean up contexts periodically
 */