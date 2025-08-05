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
//  - No singleton - injected via environment
//

import Foundation
import Combine

@MainActor
final class EventBus: EventBusProtocol, ObservableObject {
    
    // MARK: - Dependencies
    var configBus: ConfigBus? {
        didSet {
            loadConfiguration()
        }
    }
    
    // MARK: - Event Publishers
    private let eventSubject = PassthroughSubject<AetherEvent, Never>()
    
    // MARK: - Configuration
    private var configuration: EventBusConfiguration?
    private var eventHistory: [AetherEvent] = []
    private var historyLimit: Int = 0
    
    // MARK: - Public Interface
    
    /// Publisher for all events - subscribe with filters
    var events: AnyPublisher<AetherEvent, Never> {
        eventSubject.eraseToAnyPublisher()
    }
    
    /// Publish an event to the bus
    func publish(_ event: AetherEvent) {
        // Store in history if debug mode enabled
        if configuration?.debugMode?.enabled == true {
            eventHistory.append(event)
            if eventHistory.count > historyLimit {
                eventHistory.removeFirst()
            }
        }
        
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
    
    /// Subscribe to multiple event types using variadic parameters
    func subscribe<T: AetherEvent>(
        to eventTypes: T.Type...,
        handler: @escaping (T) -> Void
    ) -> AnyCancellable {
        return events
            .compactMap { event -> T? in
                for eventType in eventTypes {
                    if let typed = event as? T, type(of: typed) == eventType {
                        return typed
                    }
                }
                return nil
            }
            .sink { event in
                handler(event)
            }
    }
    
    /// Async stream subscription for modern Swift concurrency
    func asyncSubscribe<T: AetherEvent>(
        to eventType: T.Type
    ) -> AsyncStream<T> {
        AsyncStream { continuation in
            let cancellable = subscribe(to: eventType) { event in
                continuation.yield(event)
            }
            
            continuation.onTermination = { _ in
                cancellable.cancel()
            }
        }
    }
    
    // MARK: - Init
    init() {
        // ConfigBus will be set after creation due to circular dependency
    }
    
    // MARK: - Configuration
    private func loadConfiguration() {
        guard let configBus = configBus else { return }
        
        configuration = configBus.load(EventBusConfiguration.self, from: "EventBus.json")
        
        // Apply configuration
        if let debugConfig = configuration?.debugMode {
            historyLimit = debugConfig.enabled ? debugConfig.replayLastNEvents : 0
        }
    }
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
    
    /// Get event history for debugging (only in debug mode)
    var debugEventHistory: [AetherEvent] {
        configuration?.debugMode?.enabled == true ? eventHistory : []
    }
    
    /// Replay last N events for debugging
    func replayHistory<T: AetherEvent>(
        ofType eventType: T.Type,
        handler: @escaping (T) -> Void
    ) {
        guard configuration?.debugMode?.enabled == true else { return }
        
        eventHistory
            .compactMap { $0 as? T }
            .forEach { handler($0) }
    }
}