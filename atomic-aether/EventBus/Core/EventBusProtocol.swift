//
//  EventBusProtocol.swift
//  atomic-aether
//
//  ATOM 1: EventBus - Protocol for event-driven communication
//
//  Protocol-based design enables:
//  - Dependency injection instead of singletons
//  - Easy testing with mock implementations
//  - Clean separation of concerns
//

import Foundation
import Combine

/// Protocol defining event bus capabilities
@MainActor
protocol EventBusProtocol: ObservableObject {
    /// Publisher for all events
    var events: AnyPublisher<AetherEvent, Never> { get }
    
    /// Publish an event to the bus
    func publish(_ event: AetherEvent)
    
    /// Subscribe to specific event type
    func subscribe<T: AetherEvent>(
        to eventType: T.Type,
        handler: @escaping (T) -> Void
    ) -> AnyCancellable
    
    /// Subscribe to multiple event types
    func subscribe<T: AetherEvent, U: AetherEvent>(
        to types: (T.Type, U.Type),
        handler: @escaping (Any) -> Void
    ) -> AnyCancellable
}