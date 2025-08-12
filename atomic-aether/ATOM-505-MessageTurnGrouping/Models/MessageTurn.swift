//
//  MessageTurn.swift
//  atomic-aether
//
//  A conversation turn - Boss message followed by responses
//
//  ATOM 505: MessageTurnGrouping - Turn model
//
//  Atomic LEGO: Pure data model for grouped messages
//  No UI, just data transformation
//

import Foundation

struct MessageTurn: Identifiable {
    let id = UUID()
    let messages: [Message]
    let turnNumber: Int
    let startedAt: Date
    
    // Who started this turn
    var initiator: String? {
        messages.first?.speaker
    }
    
    // How many messages in this turn
    var messageCount: Int {
        messages.count
    }
    
    // Unique participants in this turn
    var participants: [String] {
        Array(Set(messages.map { $0.speaker })).sorted()
    }
    
    // Is this a complete turn (has responses)
    var isComplete: Bool {
        participants.count > 1
    }
}