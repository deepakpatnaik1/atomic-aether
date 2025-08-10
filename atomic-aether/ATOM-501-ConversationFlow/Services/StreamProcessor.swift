//
//  StreamProcessor.swift
//  atomic-aether
//
//  Processes streaming LLM responses
//
//  ATOM 501: ConversationFlow - Stream handler
//
//  Atomic LEGO: Focused service for stream processing
//  Updates messages in real-time as chunks arrive
//

import Foundation
import SwiftUI
import Combine

@MainActor
final class StreamProcessor {
    
    // MARK: - Dependencies
    
    private let messageStore: MessageStore
    private let eventBus: EventBus
    
    // MARK: - State
    
    private var activeStreams: Set<UUID> = []
    
    // MARK: - Initialization
    
    init(messageStore: MessageStore, eventBus: EventBus) {
        self.messageStore = messageStore
        self.eventBus = eventBus
    }
    
    // MARK: - Stream Processing
    
    /// Process a streaming response
    func processStream(
        _ stream: AsyncThrowingStream<LLMResponse, Error>,
        messageId: UUID,
        persona: String
    ) async {
        guard !activeStreams.contains(messageId) else { return }
        
        activeStreams.insert(messageId)
        
        // Track content and chunks
        var accumulatedContent = ""
        var chunkCount = 0
        
        do {
            for try await response in stream {
                switch response {
                case .content(let content):
                    chunkCount += 1
                    // Accumulate content and update message
                    accumulatedContent += content
                    messageStore.updateMessage(
                        messageId,
                        content: accumulatedContent,
                        isStreaming: true
                    )
                    
                    // Publish streaming event periodically (every 10 chunks)
                    if chunkCount % 10 == 0 {
                        eventBus.publish(ConversationStreamingEvent(
                            messageId: messageId,
                            contentLength: accumulatedContent.count,
                            persona: persona
                        ))
                    }
                    
                case .done:
                    break
                    
                case .error(let error):
                    throw error
                    
                case .metadata:
                    // Ignore metadata for now
                    continue
                }
            }
            
            // Finalize the message
            await finalizeStream(
                messageId: messageId,
                content: accumulatedContent,
                success: true
            )
            
        } catch {
            // Handle stream error with better error messages
            let errorMessage: String
            if let llmError = error as? LLMError {
                switch llmError {
                case .apiKeyMissing:
                    errorMessage = "⚠️ API key missing. Please set up your API keys in Settings (Cmd+Shift+,)"
                case .invalidModel(let model):
                    errorMessage = "⚠️ Invalid model: \(model)"
                case .networkError(let description):
                    errorMessage = "⚠️ Network error: \(description)"
                case .invalidResponse(let reason):
                    errorMessage = "⚠️ Invalid response: \(reason)"
                case .rateLimitExceeded:
                    errorMessage = "⚠️ Rate limit exceeded. Please try again later."
                case .streamingError(let message):
                    errorMessage = "⚠️ Streaming error: \(message)"
                case .providerError(let provider, let message):
                    errorMessage = "⚠️ \(provider) error: \(message)"
                }
            } else {
                errorMessage = "⚠️ An error occurred: \(error.localizedDescription)"
            }
            
            await finalizeStream(
                messageId: messageId,
                content: errorMessage,
                success: false
            )
        }
    }
    
    // MARK: - Private Methods
    
    private func finalizeStream(
        messageId: UUID,
        content: String,
        success: Bool
    ) async {
        // Update message to non-streaming state
        messageStore.updateMessage(
            messageId,
            content: content,
            isStreaming: false
        )
        
        activeStreams.remove(messageId)
        
        // Publish completion event
        eventBus.publish(ConversationCompletedEvent(
            messageId: messageId,
            success: success,
            contentLength: content.count
        ))
    }
}