//
//  MarkdownConfiguration.swift
//  atomic-aether
//
//  Configuration model for markdown rendering
//
//  ATOM 504: Markdown - Configuration for markdown appearance
//
//  Atomic LEGO: Maps to MarkdownAppearance.json
//  All visual properties externalized to configuration
//

import Foundation
import SwiftUI

struct MarkdownConfiguration: Codable {
    let headings: HeadingConfiguration
    let text: TextConfiguration
    let lists: ListConfiguration
    let code: CodeConfiguration
    let links: LinkConfiguration
    let blockquote: BlockquoteConfiguration
    let tables: TableConfiguration
    let defaults: DefaultConfiguration
    
    struct HeadingConfiguration: Codable {
        let h1: HeadingStyle
        let h2: HeadingStyle
        let h3: HeadingStyle
        let h4: HeadingStyle
        let h5: HeadingStyle
        let h6: HeadingStyle
        
        struct HeadingStyle: Codable {
            let fontSize: Double
            let fontWeight: String
            let opacity: Double
            let topPadding: Double
            let bottomPadding: Double
        }
    }
    
    struct TextConfiguration: Codable {
        let fontSize: Double
        let lineSpacing: Double
        let paragraphSpacing: Double
        let opacity: Double
        let boldOpacity: Double
        let italicOpacity: Double
    }
    
    struct ListConfiguration: Codable {
        let bulletIndent: Double
        let itemSpacing: Double
        let bulletOpacity: Double
        let bulletSize: Double
        let numberOpacity: Double
    }
    
    struct CodeConfiguration: Codable {
        let inlineFontSize: Double
        let inlineOpacity: Double
        let inlineBackgroundOpacity: Double
        let inlinePadding: Double
        let inlineCornerRadius: Double
        let blockFontSize: Double
        let blockOpacity: Double
        let blockBackgroundOpacity: Double
        let blockPadding: Double
        let blockCornerRadius: Double
        let fontName: String
    }
    
    struct LinkConfiguration: Codable {
        let color: String
        let underline: Bool
        let hoverOpacity: Double
    }
    
    struct BlockquoteConfiguration: Codable {
        let borderWidth: Double
        let borderOpacity: Double
        let contentOpacity: Double
        let leftPadding: Double
    }
    
    struct TableConfiguration: Codable {
        let borderOpacity: Double
        let borderWidth: Double
        let cellPadding: Double
    }
    
    struct DefaultConfiguration: Codable {
        let fontSize: Double
        let opacity: Double
    }
}

// Helper for color conversion
extension MarkdownConfiguration {
    static func color(from string: String) -> Color {
        switch string.lowercased() {
        case "blue": return .blue
        case "cyan": return .cyan
        case "mint": return .mint
        case "teal": return .teal
        case "white": return .white
        default: 
            // Try hex color
            if let color = Color(hex: string) {
                return color
            }
            return .white
        }
    }
}

