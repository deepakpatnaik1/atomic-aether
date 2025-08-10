//
//  ThemeService.swift
//  atomic-aether
//
//  Service that provides the current theme
//  
//  ATOM 601: Theme System - Configuration-driven theming via ConfigBus
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
        // Default theme from DesignTokens.default
        let defaultTokens = DesignTokens.default
        self.current = Theme(
            backgroundColor: Color(hex: defaultTokens.colors.background.primary) ?? .black,
            primaryTextColor: Color(hex: defaultTokens.colors.text.primary) ?? .white,
            secondaryTextColor: Color(hex: defaultTokens.colors.text.secondary) ?? .gray
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
            backgroundColor: Color(hex: tokens.colors.background.primary) ?? .black,
            primaryTextColor: Color(hex: tokens.colors.text.primary) ?? .white,
            secondaryTextColor: Color(hex: tokens.colors.text.secondary) ?? .gray
        )
    }
}