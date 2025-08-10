//
//  Event.swift
//  atomic-aether
//
//  Base protocol for all events in the system
//
//  ATOM 101: EventBus - Event protocol foundation
//
//  ATOMIC LEGO: Pure event definition
//  - All events conform to AetherEvent protocol
//  - Provides common properties for tracking and debugging
//  - Type-safe event categories via enums
//

import Foundation

// MARK: - Base Event Protocol

protocol AetherEvent {
    /// When the event was created
    var timestamp: Date { get }
    
    /// Which component published this event
    var source: String { get }
    
    /// Event identifier for debugging
    var eventId: UUID { get }
}

// MARK: - Default Implementation

extension AetherEvent {
    var timestamp: Date {
        Date()
    }
    
    var eventId: UUID {
        UUID()
    }
}

// MARK: - Event Categories Marker Protocols

/// Events related to user input
protocol InputEventType: AetherEvent {}

/// Events related to system state
protocol SystemEventType: AetherEvent {}

/// Events related to conversations
protocol ConversationEventType: AetherEvent {}

/// Events related to navigation
protocol NavigationEventType: AetherEvent {}