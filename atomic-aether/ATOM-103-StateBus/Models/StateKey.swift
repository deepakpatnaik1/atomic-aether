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

// Layout state keys
extension StateKey where T == CGFloat {
    static let contentWidth = StateKey<CGFloat>("layout.contentWidth")
}