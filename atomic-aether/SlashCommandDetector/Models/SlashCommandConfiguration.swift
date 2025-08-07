//
//  SlashCommandConfiguration.swift
//  atomic-aether
//
//  Configuration for slash command detector
//
//  ATOM 6: Slash Command Detector - Configuration model
//
//  Atomic LEGO: All command settings externalized
//  Hot-reloadable via ConfigBus
//

import Foundation

struct SlashCommandDetectorConfiguration: Codable {
    let commands: [SlashCommand]
    let detectCaseSensitive: Bool
    let clearTextOnExpand: Bool
    
    static let `default` = SlashCommandDetectorConfiguration(
        commands: [
            SlashCommand(
                trigger: "/journal",
                expandToLines: 34,
                description: "Expand input for journal entry"
            )
        ],
        detectCaseSensitive: false,
        clearTextOnExpand: true
    )
}