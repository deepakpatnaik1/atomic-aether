//
//  JournalConfiguration.swift
//  atomic-aether
//
//  Configuration for journal service
//
//  ATOM 24: Journal Service - Configuration model
//
//  Atomic LEGO: All journal settings externalized
//  Hot-reloadable via ConfigBus
//

import Foundation

struct JournalConfiguration: Codable {
    let journalPath: String              // Path to journal.md file
    let dateFormat: String               // Format for timestamps
    let timezone: String                 // Internal timezone for sorting
    let maxEntriesInMemory: Int         // Memory limit for performance
    let fileEncoding: String            // File encoding (usually utf8)
    let appendDelimiter: String         // Delimiter between entries
    let createPathIfMissing: Bool       // Auto-create directories
    
    static let `default` = JournalConfiguration(
        journalPath: "~/Documents/code/aetherVault/journal/journal.md",
        dateFormat: "yyyy-MM-dd HH:mm:ss",
        timezone: "Europe/Berlin",
        maxEntriesInMemory: 10000,
        fileEncoding: "utf8",
        appendDelimiter: "\n\n---\n\n",
        createPathIfMissing: true
    )
    
    // Computed property for expanded path
    var expandedJournalPath: String {
        return NSString(string: journalPath).expandingTildeInPath
    }
    
    var journalURL: URL? {
        return URL(fileURLWithPath: expandedJournalPath)
    }
}