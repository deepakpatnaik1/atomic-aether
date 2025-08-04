//
//  SuperJournalEvents.swift
//  atomic-aether
//
//  Events published by superjournal service
//
//  ATOM 25: SuperJournal Service - Event definitions
//
//  Atomic LEGO: Events for superjournal operations
//  Enables monitoring of file operations
//

import Foundation

enum SuperJournalEvent: AetherEvent {
    case fileCreated(path: String)
    case entryWritten(count: Int)
    case fileRotated(oldPath: String, newPath: String)
    case superJournalError(Error)
    
    var source: String {
        "SuperJournalService"
    }
    
    var id: String {
        switch self {
        case .fileCreated:
            return "superjournal.file.created"
        case .entryWritten:
            return "superjournal.entry.written"
        case .fileRotated:
            return "superjournal.file.rotated"
        case .superJournalError:
            return "superjournal.error"
        }
    }
    
    var metadata: [String: Any] {
        switch self {
        case .fileCreated(let path):
            return ["path": path]
        case .entryWritten(let count):
            return ["totalEntries": count]
        case .fileRotated(let oldPath, let newPath):
            return ["oldPath": oldPath, "newPath": newPath]
        case .superJournalError(let error):
            return ["error": error.localizedDescription]
        }
    }
}