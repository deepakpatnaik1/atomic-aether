//
//  ScrollbackHistoryConfiguration.swift
//  atomic-aether
//
//  Configuration for scrollback history loading
//
//  ATOM 31: Scrollback History Loader - Configuration model
//
//  Atomic LEGO: All loading behavior externalized
//  Hot-reloadable via ConfigBus
//

import Foundation

struct ScrollbackHistoryConfiguration: Codable {
    let enabled: Bool
    let messagesPerBatch: Int
    let loadTriggerThreshold: CGFloat  // Pixels from top to trigger load
    let superJournalPath: String
    let dateFormat: String
    let showLoadingIndicator: Bool
    let loadingText: String
    let loadMoreButtonText: String
    let noMoreHistoryText: String
    let errorRetryDelay: TimeInterval
    let maxRetries: Int
    let autoLoadOnScroll: Bool  // Auto-load when trigger appears
    
    // Button appearance
    let buttonStyle: ButtonStyle
    
    struct ButtonStyle: Codable {
        let backgroundColor: String
        let textColor: String
        let fontSize: CGFloat
        let padding: CGFloat
        let cornerRadius: CGFloat
        let opacity: Double
    }
    
    static let `default` = ScrollbackHistoryConfiguration(
        enabled: true,
        messagesPerBatch: 100,
        loadTriggerThreshold: 50,
        superJournalPath: "~/Documents/aetherVault/superjournal/",
        dateFormat: "yyyy-MM-dd-HH-mm-ss",
        showLoadingIndicator: true,
        loadingText: "Loading earlier messages...",
        loadMoreButtonText: "Load Earlier Messages",
        noMoreHistoryText: "Beginning of conversation history",
        errorRetryDelay: 2.0,
        maxRetries: 3,
        autoLoadOnScroll: true,
        buttonStyle: ButtonStyle(
            backgroundColor: "systemGray5",
            textColor: "label",
            fontSize: 14,
            padding: 8,
            cornerRadius: 8,
            opacity: 0.8
        )
    )
    
    // Helper to get SuperJournal URL
    var superJournalURL: URL? {
        let expandedPath = (superJournalPath as NSString).expandingTildeInPath
        return URL(fileURLWithPath: expandedPath)
    }
}