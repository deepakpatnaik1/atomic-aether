//
//  JournalEvents.swift
//  atomic-aether
//
//  Events published by journal service
//
//  ATOM 24: Journal Service - Event definitions
//
//  Atomic LEGO: Events for journal operations
//  Enables decoupled communication with other atoms
//

import Foundation

enum JournalEvent: AetherEvent {
    case entryAdded(JournalEntry)
    case journalLoaded(entryCount: Int)
    case journalError(Error)
    
    var source: String {
        "JournalService"
    }
    
    var id: String {
        switch self {
        case .entryAdded:
            return "journal.entry.added"
        case .journalLoaded:
            return "journal.loaded"
        case .journalError:
            return "journal.error"
        }
    }
    
    var metadata: [String: Any] {
        switch self {
        case .entryAdded(let entry):
            return [
                "timestamp": entry.timestamp,
                "speaker": entry.speaker,
                "hasSentiment": entry.sentiment != nil
            ]
        case .journalLoaded(let count):
            return ["entryCount": count]
        case .journalError(let error):
            return ["error": error.localizedDescription]
        }
    }
}