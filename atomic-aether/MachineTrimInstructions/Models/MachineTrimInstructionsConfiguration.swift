//
//  MachineTrimInstructionsConfiguration.swift
//  atomic-aether
//
//  Configuration for machine trim instructions
//
//  ATOM 29: Machine Trim Instructions - Configuration model
//
//  Atomic LEGO: All instruction text externalized
//  Hot-reloadable via ConfigBus
//

import Foundation

struct MachineTrimInstructionsConfiguration: Codable {
    let enabled: Bool
    let instructionTemplate: String
    let normalResponseMarker: String
    let machineTrimMarker: String
    let inferableMarker: String
    let inferableOnlyMarker: String
    let includeExamples: Bool
    let examples: [MachineTrimExample]
    let inferabilityGuidelines: [String]
    
    struct MachineTrimExample: Codable {
        let description: String
        let bossMessage: String
        let normalResponse: String
        let machineTrim: String
    }
    
    static let `default` = MachineTrimInstructionsConfiguration(
        enabled: true,
        instructionTemplate: """
        RESPONSE FORMAT INSTRUCTIONS:
        
        You must respond in a two-part format for every message:
        
        1. First, provide your normal conversational response after the marker: {normalMarker}
        2. Then, provide a compressed machine trim after the marker: {machineTrimMarker}
        
        The machine trim must:
        - Include both "Boss: [message]" and "{persona}: [compressed response]"
        - Preserve semantic meaning while removing redundancy
        - Use {inferableMarker} markers for content that can be inferred from context
        - Use {inferableOnlyMarker} if the entire response is inferable
        
        IMPORTANT: Always include the Boss's message in the machine trim, even if your response is inferable.
        """,
        normalResponseMarker: "---NORMAL_RESPONSE---",
        machineTrimMarker: "---MACHINE_TRIM---",
        inferableMarker: "[INFERABLE]",
        inferableOnlyMarker: "[INFERABLE - NOT STORED]",
        includeExamples: true,
        examples: [
            MachineTrimExample(
                description: "Simple factual exchange",
                bossMessage: "What is a red dwarf?",
                normalResponse: "A red dwarf is a small, relatively cool star that makes up the vast majority of stars in our galaxy. They burn their fuel slowly and can live for trillions of years.",
                machineTrim: "Boss: What is a red dwarf?\nClaude: red dwarf: small cool star, majority in galaxy, burns slowly, lives trillions years"
            ),
            MachineTrimExample(
                description: "Inferable response",
                bossMessage: "Thanks!",
                normalResponse: "You're welcome! Happy to help.",
                machineTrim: "Boss: Thanks!\nClaude: [INFERABLE - NOT STORED]"
            )
        ],
        inferabilityGuidelines: [
            "Use [INFERABLE] for acknowledgments like 'You're welcome', 'Happy to help'",
            "Use [INFERABLE] for obvious follow-ups that add no new information",
            "Never mark substantive information as inferable",
            "When in doubt, include the content rather than marking inferable"
        ]
    )
}