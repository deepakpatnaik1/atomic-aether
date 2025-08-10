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
    struct ColorComponents: Codable {
        let red: Double
        let green: Double
        let blue: Double
        let alpha: Double
        
        /// Convert to SwiftUI Color
        var color: Color {
            Color(red: red, green: green, blue: blue, opacity: alpha)
        }
    }
    
    struct Colors: Codable {
        struct Background: Codable {
            let primary: ColorComponents
        }
        
        struct Text: Codable {
            let primary: ColorComponents
            let secondary: ColorComponents
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
                primary: ColorComponents(red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0)
            ),
            text: Colors.Text(
                primary: ColorComponents(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0),
                secondary: ColorComponents(red: 0.7, green: 0.7, blue: 0.7, alpha: 1.0)
            )
        ),
        spacing: Spacing(small: 8, medium: 16, large: 24)
    )
}