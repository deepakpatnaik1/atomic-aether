//
//  ThemeService.swift
//  atomic-aether
//
//  Service that provides the current theme
//  
//  Atomic LEGO: Service that reads from configuration
//  Can be deleted without affecting other atoms
//

import SwiftUI

@MainActor
class ThemeService: ObservableObject {
    @Published var current: Theme
    
    init() {
        // For now, we'll hardcode the dark theme
        // In future, this will read from DesignTokens.json
        self.current = Theme(
            backgroundColor: Color(red: 0.0, green: 0.0, blue: 0.0),
            primaryTextColor: Color(red: 1.0, green: 1.0, blue: 1.0),
            secondaryTextColor: Color(red: 0.7, green: 0.7, blue: 0.7)
        )
    }
}