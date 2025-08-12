//
//  JournalCommandEvents.swift
//  atomic-aether
//
//  Events for journal command execution
//
//  ATOM 304: JournalCommand - Event definitions
//

import Foundation

// MARK: - Journal Command Events

struct JournalCommandTriggeredEvent: AetherEvent {
    let timestamp: Date
    let source: String = "JournalCommand"
}

struct JournalCommandExpandedEvent: AetherEvent {
    let lines: Int
    let source: String = "JournalCommand"
}

// MARK: - Convenience Namespace

enum JournalCommandEvent {
    static func triggered() -> JournalCommandTriggeredEvent {
        return JournalCommandTriggeredEvent(timestamp: Date())
    }
    
    static func expanded(lines: Int) -> JournalCommandExpandedEvent {
        return JournalCommandExpandedEvent(lines: lines)
    }
}