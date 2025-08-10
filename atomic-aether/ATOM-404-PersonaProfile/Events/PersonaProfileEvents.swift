//
//  PersonaProfileEvents.swift
//  atomic-aether
//
//  Events published by persona profile service
//
//  ATOM 404: Persona Profile Service - Event definitions
//
//  Atomic LEGO: Minimal events for persona profile operations
//  Avoids noise - only essential events
//

import Foundation

enum PersonaProfileEvent: AetherEvent {
    case profileLoaded(personaId: String, fileCount: Int)
    case profileError(personaId: String, error: Error)
    
    var source: String {
        "PersonaProfileService"
    }
    
    var id: String {
        switch self {
        case .profileLoaded:
            return "persona.profile.loaded"
        case .profileError:
            return "persona.profile.error"
        }
    }
    
    var metadata: [String: Any] {
        switch self {
        case .profileLoaded(let personaId, let count):
            return ["personaId": personaId, "fileCount": count]
        case .profileError(let personaId, let error):
            return ["personaId": personaId, "error": error.localizedDescription]
        }
    }
}