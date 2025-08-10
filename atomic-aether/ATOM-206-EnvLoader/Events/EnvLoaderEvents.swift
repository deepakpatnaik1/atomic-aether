//
//  EnvLoaderEvents.swift
//  atomic-aether
//
//  Events published by environment loader
//
//  ATOM 206: Environment Loader - Event definitions
//
//  Atomic LEGO: Events for environment loading status
//  Enables other atoms to react to environment changes
//

import Foundation

enum EnvLoaderEvent: AetherEvent {
    case environmentLoaded(hasKeys: Bool)
    case keychainMigrationCompleted
    case loadingFailed(reason: String)
    
    var source: String {
        "EnvLoader"
    }
    
    var id: String {
        switch self {
        case .environmentLoaded:
            return "env.loader.loaded"
        case .keychainMigrationCompleted:
            return "env.loader.keychain.migrated"
        case .loadingFailed:
            return "env.loader.failed"
        }
    }
    
    var metadata: [String: Any] {
        switch self {
        case .environmentLoaded(let hasKeys):
            return ["hasKeys": hasKeys]
        case .keychainMigrationCompleted:
            return [:]
        case .loadingFailed(let reason):
            return ["reason": reason]
        }
    }
}