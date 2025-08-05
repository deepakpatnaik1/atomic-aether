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
import Combine

@MainActor
final class StreamProcessor {
    
    // MARK: - Dependencies
    
    private let messageStore: MessageStore
    private let eventBus: EventBus
    weak var responseParser: ResponseParserService?
    
    // MARK: - State
    
    private var activeStreams: Set<UUID> = []
    private var parsedContent: [UUID: String] = [:]  // Store parsed content by messageId
    private var currentStreamingMessageId: UUID?  // Track which message is currently being parsed
    private var eventSubscription: AnyCancellable?  // Store subscription
    
    // MARK: - Initialization
    
    init(messageStore: MessageStore, eventBus: EventBus) {
        self.messageStore = messageStore
        self.eventBus = eventBus
        
        // Subscribe to ResponseParser events (Phase II)
        setupResponseParserSubscription()
    }
    
    private func setupResponseParserSubscription() {
        eventSubscription = eventBus.subscribe(to: ResponseParserEvent.self) { [weak self] event in
            guard let self = self else { return }
            
            switch event {
            case .normalToken(let token):
                // Update the current streaming message with parsed tokens only
                if let messageId = self.currentStreamingMessageId {
                    self.parsedContent[messageId, default: ""] += token
                    self.messageStore.updateMessage(
                        messageId,
                        content: self.parsedContent[messageId] ?? "",
                        isStreaming: true
                    )
                }
            case .normalResponseComplete, .machineTrimComplete, .fullyInferableResponse:
                // These are handled elsewhere
                break
            case .parsingError(let error):
                // Log error but don't interrupt streaming
                print("ResponseParser error during streaming: \(error)")
            }
        }
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
        currentStreamingMessageId = messageId
        
        // Initialize parsed content for this message
        parsedContent[messageId] = ""
        
        // Track chunks for periodic events
        var chunkCount = 0
        
        do {
            for try await response in stream {
                switch response {
                case .content(let content):
                    chunkCount += 1
                    
                    // Send to response parser if available (Phase II)
                    if let parser = responseParser {
                        // Parser will handle the tokens and publish events
                        parser.parseStreamingToken(content)
                    } else {
                        // No parser - use raw content (Phase I fallback)
                        parsedContent[messageId, default: ""] += content
                        messageStore.updateMessage(
                            messageId,
                            content: parsedContent[messageId] ?? "",
                            isStreaming: true
                        )
                    }
                    
                    // Publish streaming event periodically (every 10 chunks)
                    if chunkCount % 10 == 0 {
                        eventBus.publish(ConversationStreamingEvent(
                            messageId: messageId,
                            contentLength: parsedContent[messageId]?.count ?? 0,
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
            
            // Finalize the message with parsed content
            await finalizeStream(
                messageId: messageId,
                content: parsedContent[messageId] ?? "",
                success: true
            )
            
            // Complete response parsing (Phase II)
            responseParser?.completeResponse()
            
        } catch {
            // Handle stream error
            let errorMessage = "Error: \(error.localizedDescription)"
            let currentContent = parsedContent[messageId] ?? ""
            await finalizeStream(
                messageId: messageId,
                content: currentContent.isEmpty ? errorMessage : currentContent + "\n\n" + errorMessage,
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
        
        // Clear current streaming message if it matches
        if currentStreamingMessageId == messageId {
            currentStreamingMessageId = nil
        }
        
        // Update message to non-streaming state
        messageStore.updateMessage(
            messageId,
            content: content,
            isStreaming: false
        )
        
        // Clean up parsed content
        parsedContent.removeValue(forKey: messageId)
        
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