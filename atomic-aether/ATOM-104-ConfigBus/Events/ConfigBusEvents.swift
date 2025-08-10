//
//  ConfigBusEvents.swift
//  atomic-aether
//
//  Events for configuration changes
//

import Foundation

// MARK: - Config Event Type

protocol ConfigEventType: AetherEvent {}

// MARK: - Config Events

struct ConfigChangedEvent: ConfigEventType {
    let configName: String
    let timestamp: Date
    let source: String = "ConfigBus"
    
    init(configName: String) {
        self.configName = configName
        self.timestamp = Date()
    }
}

struct ConfigLoadFailedEvent: ConfigEventType {
    let configName: String
    let error: Error
    let source: String = "ConfigBus"
}

// MARK: - Convenience Namespace

enum ConfigEvents {
    static func changed(_ configName: String) -> ConfigChangedEvent {
        return ConfigChangedEvent(configName: configName)
    }
    
    static func loadFailed(_ configName: String, error: Error) -> ConfigLoadFailedEvent {
        return ConfigLoadFailedEvent(configName: configName, error: error)
    }
}