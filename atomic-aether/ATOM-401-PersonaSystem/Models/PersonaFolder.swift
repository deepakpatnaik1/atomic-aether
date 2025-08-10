//
//  PersonaFolder.swift
//  atomic-aether
//
//  Dynamic persona loaded from folder with frontmatter
//
//  ATOM 401: Personas - Folder-based persona model
//
//  Atomic LEGO: Represents a persona loaded from disk
//  Contains all metadata from YAML frontmatter
//

import Foundation
import SwiftUI

struct PersonaFolder: Identifiable, Equatable {
    let id: String          // folder name (lowercase)
    let folderPath: URL
    let displayName: String // From frontmatter 'name'
    let avatar: String      // From frontmatter 'avatar'
    let color: Color        // From frontmatter 'color'
    let isAnthropic: Bool   // From frontmatter 'isAnthropic'
    let personaType: String?// From frontmatter 'personaType' (Functional Expert or Cognitive Voice)
    let role: String?       // From frontmatter 'role' (2-3 word description)
    let lastModified: Date
    let content: String     // Full markdown content after frontmatter
    
    // Convert to PersonaDefinition for compatibility
    func toPersonaDefinition() -> PersonaDefinition {
        // Convert Color to ColorComponents
        let uiColor = NSColor(color)
        let components = ColorComponents(
            red: Double(uiColor.redComponent),
            green: Double(uiColor.greenComponent),
            blue: Double(uiColor.blueComponent),
            alpha: Double(uiColor.alphaComponent)
        )
        
        return PersonaDefinition(
            id: id,
            displayName: displayName,
            isAnthropic: isAnthropic,
            systemPrompt: content,
            accentColor: components,
            voiceStyle: nil,  // Not specified in frontmatter
            expertise: nil,   // Not specified in frontmatter
            personaType: personaType,
            role: role
        )
    }
}

