//
//  StateKey.swift
//  atomic-aether
//
//  Type-safe keys for StateBus storage
//
//  ATOM 103: StateBus - Type-safe state keys
//
//  Atomic LEGO: Generic key structure for any state type
//  Consuming atoms define their own keys
//

import Foundation

/// Type-safe key for StateBus storage
struct StateKey<T> {
    let name: String
    
    init(_ name: String) {
        self.name = name
    }
}

// MARK: - Common State Keys
// These will be defined by consuming atoms, not here
// Example usage in future atoms:
//
// extension StateKey {
//     static var currentModel: StateKey<String> { 
//         StateKey("currentModel") 
//     }
//     static var currentPersona: StateKey<String> { 
//         StateKey("currentPersona") 
//     }
// }