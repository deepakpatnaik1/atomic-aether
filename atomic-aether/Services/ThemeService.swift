//
//  ThemeService.swift
//  atomic-aether
//
//  Service that provides the current theme
//  
//  ATOM 1: Dark Theme - Now configuration-driven via ConfigBus
//  ATOM 6: ConfigBus - Loads theme from DesignTokens.json
//
//  Atomic LEGO: Service that reads from configuration
//  Can be deleted without affecting other atoms
//

import SwiftUI
import Combine

@MainActor
class ThemeService: ObservableObject {
    @Published var current: Theme
    
    private var configBus: ConfigBus?
    private var cancellable: AnyCancellable?
    
    init() {
        // Default theme (fallback if config fails)
        self.current = Theme(
            backgroundColor: Color(red: 0.0, green: 0.0, blue: 0.0),
            primaryTextColor: Color(red: 1.0, green: 1.0, blue: 1.0),
            secondaryTextColor: Color(red: 0.7, green: 0.7, blue: 0.7)
        )
    }
    
    /// Setup with ConfigBus for configuration-driven theming
    func setupWithConfigBus(_ configBus: ConfigBus) {
        self.configBus = configBus
        
        // Initial load
        if let tokens = configBus.load("DesignTokens", as: DesignTokens.self) {
            updateTheme(from: tokens)
        }
        
        // Watch for changes (hot-reload)
        cancellable = configBus.objectWillChange
            .sink { [weak self] _ in
                if let tokens = configBus.load("DesignTokens", as: DesignTokens.self) {
                    self?.updateTheme(from: tokens)
                }
            }
    }
    
    private func updateTheme(from tokens: DesignTokens) {
        current = Theme(
            backgroundColor: tokens.colors.background.primary.color,
            primaryTextColor: tokens.colors.text.primary.color,
            secondaryTextColor: tokens.colors.text.secondary.color
        )
    }
}