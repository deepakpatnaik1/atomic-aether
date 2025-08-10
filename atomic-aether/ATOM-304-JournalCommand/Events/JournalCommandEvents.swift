//
//  JournalCommandEvents.swift
//  atomic-aether
//
//  Events for journal command execution
//
//  ATOM 304: JournalCommand - Event definitions
//

import Foundation

// MARK: - Journal Command Event Type

protocol JournalCommandEventType: AetherEvent {}

// MARK: - Journal Command Events

struct JournalCommandTriggeredEvent: JournalCommandEventType {
    let timestamp: Date
    let source: String = "JournalCommand"
}

struct JournalCommandExpandedEvent: JournalCommandEventType {
    let lines: Int
    let prefixInserted: String?
    let source: String = "JournalCommand"
}

struct JournalCommandCompletedEvent: JournalCommandEventType {
    let entryText: String
    let timestamp: Date
    let source: String = "JournalCommand"
}

// MARK: - Convenience Namespace

enum JournalCommandEvent {
    static func triggered() -> JournalCommandTriggeredEvent {
        return JournalCommandTriggeredEvent(timestamp: Date())
    }
    
    static func expanded(lines: Int, prefix: String? = nil) -> JournalCommandExpandedEvent {
        return JournalCommandExpandedEvent(lines: lines, prefixInserted: prefix)
    }
    
    static func completed(text: String) -> JournalCommandCompletedEvent {
        return JournalCommandCompletedEvent(entryText: text, timestamp: Date())
    }
}