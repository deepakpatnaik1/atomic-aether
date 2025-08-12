//
//  MessageTurnEvents.swift
//  atomic-aether
//
//  Events published by MessageTurnService
//
//  ATOM 505: MessageTurnGrouping - Event definitions
//

import Foundation

// MARK: - Turn Events

struct TurnsUpdatedEvent: AetherEvent {
    let turnCount: Int
    let source: String = "MessageTurnService"
}

struct TurnCountChangedEvent: AetherEvent {
    let oldCount: Int
    let newCount: Int
    let source: String = "MessageTurnService"
}