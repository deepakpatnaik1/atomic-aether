//
//  HistoricalMessage.swift
//  atomic-aether
//
//  Model for messages loaded from SuperJournal
//
//  ATOM 30: Scrollback History Loader - Historical message model
//
//  Atomic LEGO: Codable wrapper for SuperJournal entries
//  Converts between file format and Message model
//

import Foundation

struct HistoricalMessage: Codable {
    let id: String
    let timestamp: Date
    let speaker: String
    let content: String
    let isUser: Bool
    let modelUsed: String?
    
    // Convert to app's Message model
    func toMessage() -> Message {
        Message(
            speaker: speaker,
            content: content,
            timestamp: timestamp,
            isStreaming: false,
            modelUsed: modelUsed
        )
    }
}

// SuperJournal file structure
struct SuperJournalFile: Codable {
    let sessionId: String
    let timestamp: Date
    let messages: [HistoricalMessage]
    let metadata: Metadata?
    
    struct Metadata: Codable {
        let appVersion: String?
        let totalMessages: Int?
        let personas: [String]?
    }
}