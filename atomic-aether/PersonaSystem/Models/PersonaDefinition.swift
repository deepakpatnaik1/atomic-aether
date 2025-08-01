//
//  PersonaDefinition.swift
//  atomic-aether
//
//  Core persona model with all properties
//
//  ATOM 13: Persona System - Persona definition
//
//  Atomic LEGO: Complete persona definition
//  - Identity and display properties
//  - Anthropic compatibility flag
//  - System prompt for LLM context
//  - Voice characteristics
//

import Foundation
import SwiftUI

struct PersonaDefinition: Codable, Identifiable {
    let id: String
    let displayName: String
    let isAnthropic: Bool
    let systemPrompt: String
    let accentColor: ColorComponents
    let voiceStyle: String? // e.g., "professional", "casual", "analytical"
    let expertise: [String]? // e.g., ["business", "strategy", "leadership"]
    
    // MARK: - Computed Properties
    
    /// SwiftUI Color from components
    var color: Color {
        accentColor.color
    }
    
    /// Whether this persona requires an Anthropic model
    var requiresAnthropicModel: Bool {
        isAnthropic
    }
    
    /// Short identifier for pattern matching (lowercase)
    var trigger: String {
        id.lowercased()
    }
}

// MARK: - Color Components

struct ColorComponents: Codable {
    let red: Double
    let green: Double
    let blue: Double
    let alpha: Double?
    
    var color: Color {
        Color(
            red: red,
            green: green,
            blue: blue,
            opacity: alpha ?? 1.0
        )
    }
}

// MARK: - Default Personas

extension PersonaDefinition {
    /// Claude - the Anthropic AI assistant
    static let claude = PersonaDefinition(
        id: "claude",
        displayName: "Claude",
        isAnthropic: true,
        systemPrompt: "You are Claude, an AI assistant created by Anthropic. You are helpful, harmless, and honest.",
        accentColor: ColorComponents(red: 0.2, green: 0.6, blue: 1.0, alpha: 1.0),
        voiceStyle: "helpful",
        expertise: ["general", "technical", "analytical"]
    )
    
    /// Default non-Anthropic persona
    static let samara = PersonaDefinition(
        id: "samara",
        displayName: "Samara",
        isAnthropic: false,
        systemPrompt: "You are Samara, a creative and innovative thinker who helps with brainstorming and problem-solving.",
        accentColor: ColorComponents(red: 0.8, green: 0.6, blue: 0.2, alpha: 1.0),
        voiceStyle: "creative",
        expertise: ["creativity", "innovation", "problem-solving"]
    )
}