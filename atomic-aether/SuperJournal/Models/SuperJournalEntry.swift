//
//  SuperJournalEntry.swift
//  atomic-aether
//
//  Entry model for superjournal persistence
//
//  ATOM 25: SuperJournal Service - Entry model
//
//  Atomic LEGO: Represents a single message in superjournal
//  Matches scrollback display format
//

import Foundation

struct SuperJournalEntry {
    let timestamp: Date
    let speaker: String
    let content: String
    let isStreaming: Bool
    
    /// Format entry for markdown file
    func formatted() -> String {
        if content.isEmpty && isStreaming {
            return "**\(speaker)**: ..."
        }
        return "**\(speaker)**: \(content)"
    }
}