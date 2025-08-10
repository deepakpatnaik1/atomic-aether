//
//  SystemEvents.swift
//  atomic-aether
//
//  Events related to system and app state
//
//  ATOM 101: EventBus - System event definitions
//
//  ATOMIC LEGO: Pure system event definitions
//  - App lifecycle, configuration changes
//  - Service status updates
//

import Foundation

// MARK: - System Events

enum SystemEvent: SystemEventType {
    case appLaunched(source: String)
    case appWillTerminate(source: String)
    case configurationLoaded(config: String, source: String)
    case configurationFailed(error: String, source: String)
    case serviceStarted(service: String, source: String)
    case serviceStopped(service: String, source: String)
    case themeChanged(theme: String, source: String)
    case modelChanged(model: String, provider: String, source: String)
    
    // MARK: - AetherEvent Conformance
    
    var source: String {
        switch self {
        case .appLaunched(let source),
             .appWillTerminate(let source),
             .configurationLoaded(_, let source),
             .configurationFailed(_, let source),
             .serviceStarted(_, let source),
             .serviceStopped(_, let source),
             .themeChanged(_, let source),
             .modelChanged(_, _, let source):
            return source
        }
    }
}

// MARK: - System State Data

struct ServiceStatus {
    let name: String
    let isRunning: Bool
    let lastError: String?
}

struct ModelConfiguration {
    let provider: String
    let model: String
    let isDefault: Bool
}