//
//  JournalEntry.swift
//  atomic-aether
//
//  Single journal entry model
//
//  ATOM 24: Journal Service - Entry model
//
//  Atomic LEGO: Pure data model for journal entries
//  Stores both local display time and internal timestamp
//

import Foundation

struct JournalEntry: Codable {
    let timestamp: Date              // System time for accurate sorting
    let localTimeString: String      // "2025-08-04 05:59:00 IST" for display
    let speaker: String
    let content: String
    let sentiment: String?           // e.g., "[frustrated → relieved]"
    let isInferable: Bool
    
    // For sorting - all entries use Berlin time internally
    var berlinTimestamp: Date {
        return timestamp
    }
    
    // Create from machine trim content
    init(from machineTrim: String, at timestamp: Date = Date()) {
        self.timestamp = timestamp
        
        // Format for display with local timezone
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        formatter.timeZone = .current
        
        self.localTimeString = formatter.string(from: timestamp) + " " +
                              (TimeZone.current.abbreviation() ?? TimeZone.current.identifier)
        
        // Parse machine trim content
        // Default values for now - will be refined when we see actual format
        self.speaker = "Unknown"
        self.content = machineTrim
        self.sentiment = nil
        self.isInferable = false
        
        // TODO: Implement actual parsing logic when machine trim format is finalized
    }
    
    // Create with explicit values (for loading from file)
    init(timestamp: Date, localTimeString: String, speaker: String, 
         content: String, sentiment: String?, isInferable: Bool) {
        self.timestamp = timestamp
        self.localTimeString = localTimeString
        self.speaker = speaker
        self.content = content
        self.sentiment = sentiment
        self.isInferable = isInferable
    }
}

// For sorting entries chronologically
extension JournalEntry: Comparable {
    static func < (lhs: JournalEntry, rhs: JournalEntry) -> Bool {
        lhs.berlinTimestamp < rhs.berlinTimestamp
    }
    
    static func == (lhs: JournalEntry, rhs: JournalEntry) -> Bool {
        lhs.timestamp == rhs.timestamp
    }
}