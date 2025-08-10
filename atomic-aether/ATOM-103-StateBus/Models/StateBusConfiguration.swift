//
//  StateBusConfiguration.swift
//  atomic-aether
//
//  Configuration model for StateBus behavior
//

import Foundation

struct StateBusConfiguration: Codable {
    let maxStorageEntries: Int
    let enableDebugLogging: Bool
}