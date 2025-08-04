//
//  SuperJournalConfiguration.swift
//  atomic-aether
//
//  Configuration for SuperJournal file persistence
//
//  ATOM 25: SuperJournal Service - Configuration model
//
//  Atomic LEGO: Defines how complete conversations are saved
//  Berlin time for filenames, local display in content
//

import Foundation

struct SuperJournalConfiguration: Codable {
    let savePath: String
    let fileFormat: String
    let maxMessagesPerFile: Int
    let timezone: String
    let includeSystemMessages: Bool
    let fileExtension: String
    let createPathIfMissing: Bool
    
    static let `default` = SuperJournalConfiguration(
        savePath: "~/Documents/aetherVault/superjournal/",
        fileFormat: "yyyy-MM-dd_HH-mm-ss",
        maxMessagesPerFile: 2000,
        timezone: "Europe/Berlin",
        includeSystemMessages: false,
        fileExtension: ".md",
        createPathIfMissing: true
    )
    
    /// Get the full save URL with expanded tilde
    var saveURL: URL? {
        let expanded = NSString(string: savePath).expandingTildeInPath
        return URL(fileURLWithPath: expanded)
    }
    
    /// Generate filename for current Berlin time
    func generateFilename() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = fileFormat
        formatter.timeZone = TimeZone(identifier: timezone) ?? .current
        return formatter.string(from: Date()) + fileExtension
    }
}