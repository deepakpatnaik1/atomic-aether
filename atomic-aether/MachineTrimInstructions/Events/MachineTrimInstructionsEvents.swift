//
//  MachineTrimInstructionsEvents.swift
//  atomic-aether
//
//  Events for machine trim instructions
//
//  ATOM 29: Machine Trim Instructions - Event definitions
//
//  Atomic LEGO: Minimal events for instruction generation
//  Only what consumers need to know
//

import Foundation

enum MachineTrimInstructionsEvent: AetherEvent {
    case instructionsGenerated(length: Int, persona: String)
    case instructionsDisabled
    case instructionsError(Error)
    
    var source: String { "MachineTrimInstructions" }
    
    var identifier: String {
        switch self {
        case .instructionsGenerated:
            return "machine.trim.instructions.generated"
        case .instructionsDisabled:
            return "machine.trim.instructions.disabled"
        case .instructionsError:
            return "machine.trim.instructions.error"
        }
    }
}