//
//  DesignTokens.swift
//  atomic-aether
//
//  Configuration model for design tokens from JSON
//
//  ATOM 601: Theme System - Design tokens configuration model
//
//  Atomic LEGO: Pure data model matching DesignTokens.json structure
//  Provides helper to convert color components to SwiftUI Color
//

import SwiftUI

struct DesignTokens: Codable {
    struct Colors: Codable {
        struct Background: Codable {
            let primary: String
        }
        
        struct Text: Codable {
            let primary: String
            let secondary: String
        }
        
        let background: Background
        let text: Text
    }
    
    struct Spacing: Codable {
        let small: Int
        let medium: Int
        let large: Int
    }
    
    let colors: Colors
    let spacing: Spacing
    
    /// Default tokens matching DesignTokens.json
    static let `default` = DesignTokens(
        colors: Colors(
            background: Colors.Background(
                primary: "#000000"
            ),
            text: Colors.Text(
                primary: "#FFFFFF",
                secondary: "#B3B3B3"
            )
        ),
        spacing: Spacing(small: 8, medium: 16, large: 24)
    )
}