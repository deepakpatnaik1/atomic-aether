//
//  ConversationConfiguration.swift
//  atomic-aether
//
//  Configuration for conversation flow
//
//  ATOM 14: ConversationFlow - Configuration model
//
//  Atomic LEGO: Settings loaded from JSON
//  Controls conversation behavior and limits
//

import Foundation

struct ConversationConfiguration: Codable {
    let maxContextMessages: Int
    let includeSystemPrompt: Bool
    let streamingEnabled: Bool
    let typingIndicatorDelay: Double
    let errorRetryAttempts: Int
    let requestTimeout: Double
    let preserveFormatting: Bool
    let userSpeakerName: String
    let sessionActiveTimeoutSeconds: Double
    
    // MARK: - Default Configuration
    
    static let `default` = ConversationConfiguration(
        maxContextMessages: 20,
        includeSystemPrompt: true,
        streamingEnabled: true,
        typingIndicatorDelay: 0.5,
        errorRetryAttempts: 2,
        requestTimeout: 30.0,
        preserveFormatting: true,
        userSpeakerName: "boss",
        sessionActiveTimeoutSeconds: 1800
    )
}