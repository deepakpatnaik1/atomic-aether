//
//  StateChange.swift
//  atomic-aether
//
//  Event model for state changes
//
//  ATOM 103: StateBus - State change event
//
//  Atomic LEGO: Simple event for notifying state mutations
//  Used with EventBus for reactive updates
//

import Foundation

/// Event fired when state changes in StateBus
struct StateChange {
    let key: String
    let timestamp: Date
    
    init(key: String) {
        self.key = key
        self.timestamp = Date()
    }
}