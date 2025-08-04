//
//  StreamProcessor.swift
//  atomic-aether
//
//  Processes streaming LLM responses
//
//  ATOM 15: Conversation Flow - Stream handler
//
//  Atomic LEGO: Focused service for stream processing
//  Updates messages in real-time as chunks arrive
//

import Foundation
import SwiftUI

@MainActor
final class StreamProcessor {
    
    // MARK: - Dependencies
    
    private let messageStore: MessageStore
    private let eventBus: EventBus
    weak var responseParser: ResponseParserService?
    
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
        // Mark stream as active
        activeStreams.insert(messageId)
        
        // Accumulate content
        var accumulatedContent = ""
        var chunkCount = 0
        
        do {
            for try await response in stream {
                switch response {
                case .content(let content):
                    accumulatedContent += content
                    chunkCount += 1
                    
                    // Send to response parser if available (Phase II)
                    responseParser?.parseStreamingToken(content)
                    
                    // Update message with accumulated content
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
            
            // Complete response parsing (Phase II)
            responseParser?.completeResponse()
            
        } catch {
            // Handle stream error
            let errorMessage = "Error: \(error.localizedDescription)"
            await finalizeStream(
                messageId: messageId,
                content: accumulatedContent.isEmpty ? errorMessage : accumulatedContent + "\n\n" + errorMessage,
                success: false
            )
        }
    }
    
    /// Check if a message is currently streaming
    func isStreaming(_ messageId: UUID) -> Bool {
        activeStreams.contains(messageId)
    }
    
    /// Cancel an active stream
    func cancelStream(_ messageId: UUID) {
        if activeStreams.contains(messageId) {
            activeStreams.remove(messageId)
            
            Task {
                messageStore.updateMessage(
                    messageId,
                    content: messageStore.message(by: messageId)?.content ?? "[Cancelled]",
                    isStreaming: false
                )
            }
        }
    }
    
    // MARK: - Private Methods
    
    private func finalizeStream(
        messageId: UUID,
        content: String,
        success: Bool
    ) async {
        // Remove from active streams
        activeStreams.remove(messageId)
        
        // Update message to non-streaming state
        messageStore.updateMessage(
            messageId,
            content: content,
            isStreaming: false
        )
        
        // Publish completion event
        eventBus.publish(ConversationStreamCompletedEvent(
            messageId: messageId,
            success: success,
            finalLength: content.count
        ))
    }
}

// MARK: - Streaming Events

struct ConversationStreamingEvent: AetherEvent, ConversationEventType {
    let messageId: UUID
    let contentLength: Int
    let persona: String
    let source: String = "StreamProcessor"
}

struct ConversationStreamCompletedEvent: AetherEvent, ConversationEventType {
    let messageId: UUID
    let success: Bool
    let finalLength: Int
    let source: String = "StreamProcessor"
}