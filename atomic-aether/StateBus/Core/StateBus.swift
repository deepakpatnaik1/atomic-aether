//
//  StateBus.swift
//  atomic-aether
//
//  Central state management for sharing data between atoms
//
//  ATOM 3: StateBus - Shared state container
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
    
    /// EventBus for publishing state changes
    private let eventBus: EventBus
    
    /// Configuration loaded from JSON
    private var configuration: StateBusConfiguration?
    
    // MARK: - Initialization
    
    init(eventBus: EventBus, configBus: ConfigBus? = nil) {
        self.eventBus = eventBus
        
        // Load configuration if available
        if let config = configBus?.load("StateBus", as: StateBusConfiguration.self) {
            self.configuration = config
        }
    }
    
    // MARK: - Public Interface
    
    /// Get a value from state
    func get<T>(_ key: StateKey<T>) -> T? {
        return storage[key.name] as? T
    }
    
    /// Set a value in state
    func set<T>(_ key: StateKey<T>, value: T?) {
        // Check storage limit
        if let max = configuration?.maxStorageEntries,
           storage.count >= max && storage[key.name] == nil {
            // Remove oldest entry (simple FIFO)
            if let firstKey = storage.keys.first {
                storage.removeValue(forKey: firstKey)
            }
        }
        
        let oldValue = storage[key.name]
        storage[key.name] = value
        
        // Debug logging if enabled
        if configuration?.enableDebugLogging == true {
            print("[StateBus] Set '\(key.name)' = \(String(describing: value))")
        }
        
        // Notify SwiftUI of change
        objectWillChange.send()
        
        // Publish event for other atoms
        eventBus.publish(StateChangedEvent(
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
        return storage[key.name] != nil
    }
    
    /// Clear all state
    func clear() {
        storage.removeAll()
        
        objectWillChange.send()
        eventBus.publish(StateClearedEvent())
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