//
//  MessageStoreConfiguration.swift
//  atomic-aether
//
//  Configuration for message storage
//
//  ATOM 503: Message Store - Configuration model
//
//  Atomic LEGO: Configuration structure for message storage
//  Loaded from MessageStore.json via ConfigBus
//

import Foundation

struct MessageStoreConfiguration: Codable {
    let maxMessages: Int
    let persistMessages: Bool
    let publishEvents: Bool
    let persistenceFileName: String?
    let loadMessagesOnStartup: Bool
    
    // MARK: - Default Configuration
    
    static let `default` = MessageStoreConfiguration(
        maxMessages: 1000,
        persistMessages: false,
        publishEvents: true,
        persistenceFileName: "messages.json",
        loadMessagesOnStartup: true
    )
}