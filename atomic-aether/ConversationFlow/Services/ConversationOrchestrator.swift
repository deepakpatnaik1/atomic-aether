//
//  ConversationOrchestrator.swift
//  atomic-aether
//
//  Orchestrates conversation flow between user and personas
//
//  ATOM 14: ConversationFlow - Main orchestrator
//
//  Atomic LEGO: Coordinates all conversation components
//  Links persona detection, model selection, and LLM calls
//

import Foundation
import SwiftUI
import Combine

@MainActor
final class ConversationOrchestrator: ObservableObject {
    
    // MARK: - Published Properties
    
    @Published var isProcessing = false
    @Published var currentContext: ConversationContext?
    @Published var error: Error?
    
    // MARK: - Dependencies
    
    private let configBus: ConfigBus
    private let eventBus: EventBus
    private let errorBus: ErrorBus
    private let personaStateService: PersonaStateService
    private let llmRouter: LLMRouter
    private let messageStore: MessageStore
    
    private var configuration: ConversationConfiguration = .default
    private var streamProcessor: StreamProcessor?
    private weak var responseParser: ResponseParserService?
    private weak var systemPromptBuilder: SystemPromptBuilderService?
    
    // MARK: - Initialization
    
    init(
        configBus: ConfigBus,
        eventBus: EventBus,
        errorBus: ErrorBus,
        personaStateService: PersonaStateService,
        llmRouter: LLMRouter,
        messageStore: MessageStore
    ) {
        self.configBus = configBus
        self.eventBus = eventBus
        self.errorBus = errorBus
        self.personaStateService = personaStateService
        self.llmRouter = llmRouter
        self.messageStore = messageStore
    }
    
    // MARK: - Setup
    
    func setup() {
        // Load configuration
        if let config = configBus.load("ConversationFlow", as: ConversationConfiguration.self) {
            self.configuration = config
        }
        
        // Initialize stream processor
        self.streamProcessor = StreamProcessor(
            messageStore: messageStore,
            eventBus: eventBus
        )
    }
    
    // MARK: - Public Methods
    
    /// Set the response parser for Phase II features
    func setResponseParser(_ parser: ResponseParserService) {
        self.responseParser = parser
        self.streamProcessor?.responseParser = parser
    }
    
    /// Set the system prompt builder for Phase II features
    func setSystemPromptBuilder(_ builder: SystemPromptBuilderService) {
        self.systemPromptBuilder = builder
    }
    
    /// Process a user message through the conversation flow
    func processMessage(_ text: String) async {
        guard !isProcessing else { return }
        guard !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        
        isProcessing = true
        error = nil
        
        do {
            // 1. Process with PersonaStateService
            let (persona, cleanedMessage) = personaStateService.processMessage(text)
            
            // 2. Create or update context
            if currentContext == nil || currentContext?.currentPersona != persona {
                currentContext = ConversationContext(
                    persona: persona,
                    model: personaStateService.modelForCurrentPersona()
                )
                
                eventBus.publish(ConversationStartedEvent(
                    sessionId: currentContext!.sessionId,
                    persona: persona,
                    model: currentContext!.currentModel
                ))
            }
            
            currentContext?.recordActivity()
            
            // 3. Add user message to store
            let userMessage = Message(
                speaker: configuration.userSpeakerName,
                content: cleanedMessage
            )
            messageStore.addMessage(userMessage)
            
            eventBus.publish(ConversationMessageSentEvent(
                sessionId: currentContext!.sessionId,
                messageId: userMessage.id,
                persona: persona,
                content: cleanedMessage
            ))
            
            // 4. Get conversation history
            let history = messageStore.messages.suffix(configuration.maxContextMessages)
            
            // 5. Create conversation request
            let systemPrompt = systemPromptBuilder?.buildSystemPrompt(personaId: persona) 
                ?? personaStateService.systemPromptForCurrentPersona()
            
            let request = ConversationRequest(
                userMessage: cleanedMessage,
                persona: persona,
                systemPrompt: systemPrompt,
                model: personaStateService.modelForCurrentPersona(),
                conversationHistory: Array(history.dropLast()), // Exclude the message we just added
                maxTokens: nil,
                temperature: nil,
                streamingEnabled: configuration.streamingEnabled
            )
            
            // 6. Create placeholder response message first
            let responseMessage = Message(
                speaker: persona,
                content: "",
                isStreaming: configuration.streamingEnabled,
                modelUsed: request.model
            )
            messageStore.addMessage(responseMessage)
            
            // 7. Send to LLM
            let llmRequest = request.toLLMRequest()
            
            do {
                let stream = try await llmRouter.sendMessage(llmRequest)
            
            // 8. Process response stream
            if configuration.streamingEnabled {
                await streamProcessor?.processStream(
                    stream,
                    messageId: responseMessage.id,
                    persona: persona
                )
            } else {
                // Non-streaming: collect full response
                var fullResponse = ""
                for try await response in stream {
                    switch response {
                    case .content(let content):
                        fullResponse += content
                    case .done:
                        break
                    case .error(let error):
                        throw error
                    case .metadata:
                        continue
                    }
                }
                
                messageStore.updateMessage(
                    responseMessage.id,
                    content: fullResponse,
                    isStreaming: false
                )
            }
            
            eventBus.publish(ConversationResponseReceivedEvent(
                sessionId: currentContext!.sessionId,
                messageId: responseMessage.id,
                persona: persona,
                model: request.model
            ))
            
            } catch {
                // Update the placeholder message with error
                let errorMessage: String
                if let llmError = error as? LLMError {
                    switch llmError {
                    case .apiKeyMissing:
                        errorMessage = "API key missing. Please set up your API keys in Settings (Cmd+Shift+,)"
                    case .invalidModel(let model):
                        errorMessage = "Invalid model: \(model)"
                    case .networkError(let description):
                        errorMessage = "Network error: \(description)"
                    case .invalidResponse(let reason):
                        errorMessage = "Invalid response: \(reason)"
                    case .rateLimitExceeded:
                        errorMessage = "Rate limit exceeded. Please try again later."
                    case .streamingError(let message):
                        errorMessage = "Streaming error: \(message)"
                    case .providerError(let provider, let message):
                        errorMessage = "\(provider) error: \(message)"
                    }
                } else {
                    errorMessage = "Error: \(error.localizedDescription)"
                }
                
                messageStore.updateMessage(
                    responseMessage.id,
                    content: "⚠️ \(errorMessage)",
                    isStreaming: false
                )
                
                // Re-throw to be caught by outer catch
                throw error
            }
            
        } catch {
            self.error = error
            
            errorBus.report(
                error,
                from: "ConversationOrchestrator",
                severity: .error
            )
            
            if let context = currentContext {
                eventBus.publish(ConversationErrorEvent(
                    sessionId: context.sessionId,
                    error: error.localizedDescription,
                    persona: context.currentPersona,
                    retryAttempt: 0
                ))
            }
        }
        
        isProcessing = false
    }
    
    /// Clear current conversation context
    func clearContext() {
        currentContext = nil
    }
    
    /// Check if conversation is active
    var hasActiveConversation: Bool {
        currentContext?.isActive(timeoutSeconds: configuration.sessionActiveTimeoutSeconds) ?? false
    }
}