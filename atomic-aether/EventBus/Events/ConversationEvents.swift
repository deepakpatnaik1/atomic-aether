//
//  ConversationEvents.swift
//  atomic-aether
//
//  Events related to conversations and messaging
//
//  ATOM 1: EventBus - Conversation event definitions
//
//  ATOMIC LEGO: Pure conversation event definitions
//  - Message flow, persona detection, responses
//  - Memory system events
//

import Foundation

// MARK: - Conversation Events

enum ConversationEvent: ConversationEventType {
    case personaDetected(name: String, message: String, source: String)
    case personaSwitched(from: String?, to: String, source: String)
    case messageComposed(content: String, attachments: [AttachmentData], source: String)
    case messageSent(id: UUID, content: String, persona: String, source: String)
    case responseReceived(id: UUID, content: String, persona: String, source: String)
    case responseStreaming(id: UUID, partialContent: String, source: String)
    case turnSaved(id: UUID, journalPath: String, source: String)
    case memoryUpdated(type: MemoryUpdateType, source: String)
    
    // MARK: - AetherEvent Conformance
    
    var source: String {
        switch self {
        case .personaDetected(_, _, let source),
             .personaSwitched(_, _, let source),
             .messageComposed(_, _, let source),
             .messageSent(_, _, _, let source),
             .responseReceived(_, _, _, let source),
             .responseStreaming(_, _, let source),
             .turnSaved(_, _, let source),
             .memoryUpdated(_, let source):
            return source
        }
    }
}

// MARK: - Conversation Data Types

struct AttachmentData {
    let id: UUID
    let name: String
    let type: String
    let size: Int64
    let content: Data
}

enum MemoryUpdateType {
    case journalEntryAdded(path: String)
    case superjournalUpdated(path: String)
    case taxonomyEvolved(categories: [String])
    case trimGenerated(path: String)
}