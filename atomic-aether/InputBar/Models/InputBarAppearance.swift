//
//  InputBarAppearance.swift
//  atomic-aether
//
//  Pure data model for input bar visual appearance
//
//  Atomic LEGO: Model for input bar styling
//  No logic, just data structure matching JSON
//

import Foundation
import SwiftUI

struct InputBarAppearance: Codable {
    let dimensions: Dimensions
    let padding: Padding
    let glassmorphic: Glassmorphic
    let shadows: Shadows
    let textField: TextField
    let multiline: Multiline
    let controls: Controls
    
    struct Dimensions: Codable {
        let width: Double
        let defaultHeight: Double
        let bottomMargin: Double
        let textFieldMinHeight: Double
        let cornerRadius: Double
    }
    
    struct Padding: Codable {
        let uniform: Double
        let horizontal: Double
    }
    
    struct Glassmorphic: Codable {
        let backgroundOpacity: Double
        let borderTopOpacity: Double
        let borderBottomOpacity: Double
        let blurRadius: Double
    }
    
    struct Shadows: Codable {
        let outer: Shadow
        let inner: Shadow
        
        struct Shadow: Codable {
            let color: String
            let opacity: Double
            let radius: Double
            let x: Double
            let y: Double
        }
    }
    
    struct TextField: Codable {
        let textColor: String
        let fontSize: Double
        let fontFamily: String
    }
    
    struct Multiline: Codable {
        let enabled: Bool
        let maxLines: Int
        let lineHeight: Double
    }
    
    struct Controls: Codable {
        let spacing: Double
        let plusButton: PlusButton
        let modelPicker: ModelPicker
        let greenIndicator: GreenIndicator
        
        struct PlusButton: Codable {
            let iconName: String
            let size: Double
            let opacity: Double
        }
        
        struct ModelPicker: Codable {
            let text: String
            let fontSize: Double
            let opacity: Double
        }
        
        struct GreenIndicator: Codable {
            let size: Double
            let color: String
            let glowRadius1: Double
            let glowRadius2: Double
            let glowOpacity: Double
        }
    }
}

// MARK: - Color Helper
extension InputBarAppearance {
    static func color(from string: String) -> Color {
        switch string.lowercased() {
        case "black": return .black
        case "white": return .white
        case "green": return .green
        case "blue": return .blue
        case "red": return .red
        default: return .black
        }
    }
}