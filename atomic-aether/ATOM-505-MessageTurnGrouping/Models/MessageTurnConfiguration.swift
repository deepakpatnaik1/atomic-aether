//
//  MessageTurnConfiguration.swift
//  atomic-aether
//
//  Configuration for message turn grouping behavior
//
//  ATOM 505: MessageTurnGrouping - Configuration
//

import Foundation

struct MessageTurnConfiguration: Codable {
    let turnDelimiter: String
    let includeSingleMessageTurns: Bool
    let maxMessagesPerTurn: Int
    let publishEvents: Bool
    
    static let `default` = MessageTurnConfiguration(
        turnDelimiter: "Boss",
        includeSingleMessageTurns: true,
        maxMessagesPerTurn: 100,
        publishEvents: true
    )
}