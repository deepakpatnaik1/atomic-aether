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

enum StateEvents: StateEventType {
    case changed(key: String, oldValue: Any?, newValue: Any?)
    case cleared
    
    // MARK: - AetherEvent Conformance
    
    var source: String {
        return "StateBus"
    }
}

// MARK: - Convenience Extensions

extension StateEvents {
    /// Create a simple change event without old value
    static func changed(key: String) -> StateEvents {
        return .changed(key: key, oldValue: nil, newValue: nil)
    }
}