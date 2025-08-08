//
//  Color+Hex.swift
//  atomic-aether
//
//  Shared Color extension for hex string initialization
//
//  Used by PersonaSystem and BossProfile for parsing colors from markdown frontmatter
//

import SwiftUI

extension Color {
    init?(hex: String?) {
        guard let hex = hex else { return nil }
        
        let r, g, b: Double
        let hexColor = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        let scanner = Scanner(string: hexColor)
        var hexNumber: UInt64 = 0
        
        if scanner.scanHexInt64(&hexNumber) {
            r = Double((hexNumber & 0xff0000) >> 16) / 255
            g = Double((hexNumber & 0x00ff00) >> 8) / 255
            b = Double(hexNumber & 0x0000ff) / 255
            
            self.init(red: r, green: g, blue: b)
            return
        }
        
        return nil
    }
}