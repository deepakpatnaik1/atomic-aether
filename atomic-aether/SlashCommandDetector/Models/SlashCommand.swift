//
//  SlashCommand.swift
//  atomic-aether
//
//  Model for slash command configuration
//
//  ATOM 22: Slash Command Detector - Command data model
//
//  Atomic LEGO: Pure data model for slash commands
//  Matches JSON structure for easy configuration
//

import Foundation

struct SlashCommand: Codable, Equatable, Identifiable {
    let trigger: String
    let expandToLines: Int?
    let description: String?
    
    var id: String { trigger }
    
    /// Display name without the leading slash
    var name: String {
        trigger.hasPrefix("/") ? String(trigger.dropFirst()) : trigger
    }
}