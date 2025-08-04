//
//  BossProfileEvents.swift
//  atomic-aether
//
//  Events published by boss profile service
//
//  ATOM 26: Boss Profile Service - Event definitions
//
//  Atomic LEGO: Minimal events for profile operations
//  Avoids noise - only essential events
//

import Foundation

enum BossProfileEvent: AetherEvent {
    case profileLoaded(fileCount: Int)
    case profileError(Error)
    
    var source: String {
        "BossProfileService"
    }
    
    var id: String {
        switch self {
        case .profileLoaded:
            return "boss.profile.loaded"
        case .profileError:
            return "boss.profile.error"
        }
    }
    
    var metadata: [String: Any] {
        switch self {
        case .profileLoaded(let count):
            return ["fileCount": count]
        case .profileError(let error):
            return ["error": error.localizedDescription]
        }
    }
}