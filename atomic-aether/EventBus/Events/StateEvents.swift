//
//  StateEvents.swift
//  atomic-aether
//
//  Events for StateBus state changes
//
//  ATOM 10: StateBus - State change events
//
//  ATOMIC LEGO: Events fired when shared state changes
//  - Allows atoms to react to state mutations
//  - Decoupled state synchronization
//

import Foundation

// MARK: - State Event Type

protocol StateEventType: AetherEvent {}

// MARK: - State Events

struct StateChangedEvent: StateEventType {
    let key: String
    let oldValue: Any?
    let newValue: Any?
    let source: String = "StateBus"
}

struct StateClearedEvent: StateEventType {
    let source: String = "StateBus"
}

// MARK: - Convenience Namespace

enum StateEvents {
    /// Create a changed event
    static func changed(key: String, oldValue: Any? = nil, newValue: Any? = nil) -> StateChangedEvent {
        return StateChangedEvent(key: key, oldValue: oldValue, newValue: newValue)
    }
    
    /// Create a cleared event
    static var cleared: StateClearedEvent {
        return StateClearedEvent()
    }
}