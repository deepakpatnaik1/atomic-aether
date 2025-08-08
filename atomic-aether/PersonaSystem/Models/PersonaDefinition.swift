//
//  PersonaDefinition.swift
//  atomic-aether
//
//  Core persona model with all properties
//
//  ATOM 10: Personas - Persona definition
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
    let personaType: String? // "Functional Expert" or "Cognitive Voice"
    let role: String? // 2-3 word role description
    
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

