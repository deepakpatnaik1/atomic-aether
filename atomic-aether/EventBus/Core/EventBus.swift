//
//  EventBus.swift
//  atomic-aether
//
//  Central nervous system for event-driven communication
//
//  ATOM 5: EventBus - The nervous system enabling true Atomic LEGO
//  
//  ATOMIC LEGO: Pure event routing with zero coupling
//  - Publish events without knowing subscribers
//  - Subscribe to events without knowing publishers
//  - Type-safe event handling with Combine
//

import Foundation
import Combine

@MainActor
final class EventBus: ObservableObject {
    
    // MARK: - Singleton
    static let shared = EventBus()
    
    // MARK: - Event Publishers
    private let eventSubject = PassthroughSubject<AetherEvent, Never>()
    
    // MARK: - Public Interface
    
    /// Publisher for all events - subscribe with filters
    var events: AnyPublisher<AetherEvent, Never> {
        eventSubject.eraseToAnyPublisher()
    }
    
    /// Publish an event to the bus
    func publish(_ event: AetherEvent) {
        eventSubject.send(event)
    }
    
    /// Subscribe to specific event type
    func subscribe<T: AetherEvent>(
        to eventType: T.Type,
        handler: @escaping (T) -> Void
    ) -> AnyCancellable {
        return events
            .compactMap { $0 as? T }
            .sink { event in
                handler(event)
            }
    }
    
    /// Subscribe to multiple event types
    func subscribe<T: AetherEvent, U: AetherEvent>(
        to types: (T.Type, U.Type),
        handler: @escaping (Any) -> Void
    ) -> AnyCancellable {
        return events
            .compactMap { event -> Any? in
                if let typed = event as? T { return typed }
                if let typed = event as? U { return typed }
                return nil
            }
            .sink { event in
                handler(event)
            }
    }
    
    // MARK: - Private Init
    private init() {}
}

// MARK: - Convenience Extensions

extension EventBus {
    
    /// Subscribe with automatic lifecycle management
    func autoSubscribe<T: AetherEvent>(
        to eventType: T.Type,
        storeIn cancellables: inout Set<AnyCancellable>,
        handler: @escaping (T) -> Void
    ) {
        subscribe(to: eventType, handler: handler)
            .store(in: &cancellables)
    }
    
    /// Filtered subscription
    func subscribe<T: AetherEvent>(
        to eventType: T.Type,
        where predicate: @escaping (T) -> Bool,
        handler: @escaping (T) -> Void
    ) -> AnyCancellable {
        return events
            .compactMap { $0 as? T }
            .filter(predicate)
            .sink { event in
                handler(event)
            }
    }
}