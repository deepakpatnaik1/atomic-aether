//
//  DevKeysEvents.swift
//  atomic-aether
//
//  Events published by DevKeys atom
//

import Foundation

enum DevKeysEvent: AetherEvent {
    case modeChanged(enabled: Bool)
    case keySaved(type: DevKeyType)
    case keyDeleted(type: DevKeyType)
    case allKeysCleared
    case migratedFromKeychain(count: Int)
    
    var source: String {
        return "DevKeys"
    }
}