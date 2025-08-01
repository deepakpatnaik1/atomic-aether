//
//  StateBus.swift
//  atomic-aether
//
//  Central state management for sharing data between atoms
//
//  ATOM 10: StateBus - Shared state container
//
//  Atomic LEGO: Generic state storage with type safety
//  - Any atom can store/retrieve state
//  - Type-safe with StateKey<T>
//  - Reactive updates via Combine
//  - Thread-safe with @MainActor
//

import Foundation
import SwiftUI
import Combine

@MainActor
final class StateBus: ObservableObject {
    
    // MARK: - Properties
    
    /// Internal storage for state values
    private var storage: [String: Any] = [:]
    
    /// Lock for thread-safe access (even though we're @MainActor)
    private let lock = NSLock()
    
    /// EventBus for publishing state changes
    private let eventBus: EventBus
    
    // MARK: - Initialization
    
    init(eventBus: EventBus) {
        self.eventBus = eventBus
    }
    
    // MARK: - Public Interface
    
    /// Get a value from state
    func get<T>(_ key: StateKey<T>) -> T? {
        lock.lock()
        defer { lock.unlock() }
        return storage[key.name] as? T
    }
    
    /// Set a value in state
    func set<T>(_ key: StateKey<T>, value: T?) {
        lock.lock()
        let oldValue = storage[key.name]
        storage[key.name] = value
        lock.unlock()
        
        // Notify SwiftUI of change
        objectWillChange.send()
        
        // Publish event for other atoms
        eventBus.publish(StateEvents.changed(
            key: key.name,
            oldValue: oldValue,
            newValue: value
        ))
    }
    
    /// Remove a value from state
    func remove<T>(_ key: StateKey<T>) {
        set(key, value: nil as T?)
    }
    
    /// Check if a key exists
    func contains<T>(_ key: StateKey<T>) -> Bool {
        lock.lock()
        defer { lock.unlock() }
        return storage[key.name] != nil
    }
    
    /// Clear all state
    func clear() {
        lock.lock()
        storage.removeAll()
        lock.unlock()
        
        objectWillChange.send()
        eventBus.publish(StateEvents.cleared)
    }
    
    // MARK: - Convenience Methods
    
    /// Get with default value
    func get<T>(_ key: StateKey<T>, default defaultValue: T) -> T {
        get(key) ?? defaultValue
    }
    
    /// Update value using closure
    func update<T>(_ key: StateKey<T>, transform: (T?) -> T?) {
        let newValue = transform(get(key))
        set(key, value: newValue)
    }
}