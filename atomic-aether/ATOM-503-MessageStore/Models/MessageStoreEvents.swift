//
//  MessageStoreEvents.swift
//  atomic-aether
//
//  Events for message store operations
//
//  ATOM 503: Message Store - Event definitions
//
//  Atomic LEGO: Events published by MessageStore
//  Enable other atoms to react to message changes
//

import Foundation

// MARK: - Message Store Events

struct MessageAddedEvent: AetherEvent, SystemEventType {
    let message: Message
    let source: String = "MessageStore"
}

struct MessageUpdatedEvent: AetherEvent, SystemEventType {
    let message: Message
    let source: String = "MessageStore"
}

struct MessagesCleared: AetherEvent, SystemEventType {
    let source: String = "MessageStore"
}

struct HistoricalMessagesLoadedEvent: AetherEvent, SystemEventType {
    let count: Int
    let source: String = "MessageStore"
}

struct MessagesPersisted: AetherEvent, SystemEventType {
    let count: Int
    let source: String = "MessageStore"
}

struct MessagesLoaded: AetherEvent, SystemEventType {
    let count: Int
    let source: String = "MessageStore"
}