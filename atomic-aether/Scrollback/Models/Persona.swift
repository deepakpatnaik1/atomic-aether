//
//  Persona.swift
//  atomic-aether
//
//  Persona configuration model
//
//  ATOM 15: Scrollback - Persona definition
//
//  Atomic LEGO: Maps to Personas.json configuration
//  Defines display name and accent color for speakers
//

import Foundation
import SwiftUI

struct Persona: Codable {
    let displayName: String
    let accentColor: ColorComponents
    
    struct ColorComponents: Codable {
        let red: Double
        let green: Double
        let blue: Double
        
        var color: Color {
            Color(red: red, green: green, blue: blue)
        }
    }
}

struct PersonasConfiguration: Codable {
    let personas: [String: Persona]  // Key is persona ID (e.g., "boss", "system")
}