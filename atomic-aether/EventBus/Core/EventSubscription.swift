//
//  EventSubscription.swift
//  atomic-aether
//
//  Subscription lifecycle management
//
//  ATOM 5: EventBus - Subscription management
//
//  ATOMIC LEGO: Clean subscription handling
//  - Automatic cancellation on dealloc
//  - Type-safe subscription builders
//  - Memory leak prevention
//

import Foundation
import Combine

// MARK: - Subscription Container

/// Container for managing multiple event subscriptions
final class EventSubscriptions {
    private var cancellables = Set<AnyCancellable>()
    
    /// Add a cancellable to be managed
    func store(_ cancellable: AnyCancellable) {
        cancellable.store(in: &cancellables)
    }
    
    /// Cancel all subscriptions
    func cancelAll() {
        cancellables.forEach { $0.cancel() }
        cancellables.removeAll()
    }
    
    deinit {
        cancelAll()
    }
}

// MARK: - Subscription Builder

/// Type-safe builder for event subscriptions
@MainActor
struct EventSubscriptionBuilder {
    private let eventBus = EventBus.shared
    private let subscriptions = EventSubscriptions()
    
    /// Subscribe to an event type
    @discardableResult
    func on<T: AetherEvent>(
        _ eventType: T.Type,
        perform handler: @escaping (T) -> Void
    ) -> EventSubscriptionBuilder {
        let cancellable = eventBus.subscribe(to: eventType, handler: handler)
        subscriptions.store(cancellable)
        return self
    }
    
    /// Subscribe with a filter
    @discardableResult
    func on<T: AetherEvent>(
        _ eventType: T.Type,
        where predicate: @escaping (T) -> Bool,
        perform handler: @escaping (T) -> Void
    ) -> EventSubscriptionBuilder {
        let cancellable = eventBus.subscribe(
            to: eventType,
            where: predicate,
            handler: handler
        )
        subscriptions.store(cancellable)
        return self
    }
    
    /// Build and return the subscription container
    func build() -> EventSubscriptions {
        subscriptions
    }
}

// MARK: - ObservableObject Extension

extension ObservableObject where Self: AnyObject {
    
    /// Create event subscriptions with automatic lifecycle management
    @MainActor
    func setupEventSubscriptions(_ builder: (EventSubscriptionBuilder) -> EventSubscriptionBuilder) -> EventSubscriptions {
        let subscriptionBuilder = EventSubscriptionBuilder()
        return builder(subscriptionBuilder).build()
    }
}