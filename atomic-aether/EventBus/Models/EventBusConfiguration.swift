//
//  EventBusConfiguration.swift
//  atomic-aether
//
//  Configuration model for EventBus behavior
//

import Foundation

struct EventBusConfiguration: Codable {
    let enableLogging: Bool
    let logLevel: String
    let asyncProcessing: Bool
    let maxConcurrentHandlers: Int
    let debugMode: DebugConfiguration?
    
    struct DebugConfiguration: Codable {
        let enabled: Bool
        let replayLastNEvents: Int
    }
}