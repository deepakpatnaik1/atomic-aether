//
//  SlashCommandEvents.swift
//  atomic-aether
//
//  Events published by slash command detector
//
//  ATOM 6: Slash Command Detector - Event definitions
//
//  Atomic LEGO: Events for command detection and state changes
//  Enables decoupled communication with other atoms
//

import Foundation

enum SlashCommandEvent: AetherEvent {
    case commandDetected(command: SlashCommand)
    case commandExpanded(command: SlashCommand, lines: Int)
    case commandCollapsed
    case commandExecuted(command: SlashCommand, text: String)
    
    var source: String {
        "SlashCommandDetector"
    }
    
    var id: String {
        switch self {
        case .commandDetected:
            return "slash.command.detected"
        case .commandExpanded:
            return "slash.command.expanded"
        case .commandCollapsed:
            return "slash.command.collapsed"
        case .commandExecuted:
            return "slash.command.executed"
        }
    }
    
    var metadata: [String: Any] {
        switch self {
        case .commandDetected(let command):
            return ["command": command.trigger]
        case .commandExpanded(let command, let lines):
            return ["command": command.trigger, "lines": lines]
        case .commandCollapsed:
            return [:]
        case .commandExecuted(let command, let text):
            return ["command": command.trigger, "textLength": text.count]
        }
    }
}