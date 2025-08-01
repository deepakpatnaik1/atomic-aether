//
//  SlashCommand.swift
//  atomic-aether
//
//  Model for slash command configuration
//
//  ATOM 4: /journal Slash Command - Command data model
//
//  Atomic LEGO: Pure data model for slash commands
//  Matches JSON structure for easy configuration
//

import Foundation

struct SlashCommand: Codable, Equatable {
    let trigger: String
    let expandToLines: Int?
    let description: String
}

struct SlashCommandConfiguration: Codable {
    let commands: [SlashCommand]
}