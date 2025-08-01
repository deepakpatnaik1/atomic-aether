//
//  KeyboardService.swift
//  atomic-aether
//
//  Handles keyboard input behavior
//
//  ATOM 16: Smart Enter Key - Service layer
//
//  Atomic LEGO: Service that determines submit vs newline
//  Based on configuration and modifier keys
//

import SwiftUI

@MainActor
class KeyboardService: ObservableObject {
    
    // MARK: - Properties
    
    @Published private(set) var configuration: KeyboardConfiguration
    private weak var configBus: ConfigBus?
    
    // MARK: - Initialization
    
    init() {
        self.configuration = .default
    }
    
    // MARK: - Setup
    
    func setupWithConfigBus(_ configBus: ConfigBus) {
        self.configBus = configBus
        loadConfiguration()
    }
    
    private func loadConfiguration() {
        if let loadedConfig = configBus?.load("KeyboardBehavior", as: KeyboardConfiguration.self) {
            self.configuration = loadedConfig
        }
    }
    
    // MARK: - Key Handling
    
    /// Check if keyboard behavior is enabled
    var isEnabled: Bool {
        configuration.enabled
    }
    
    /// Get a user-friendly description of the keyboard shortcuts
    func shortcutDescription() -> (submit: String, newline: String) {
        let submit = "Enter"
        
        var newlineOptions: [String] = []
        if configuration.hasShiftModifier() {
            newlineOptions.append("Shift+Enter")
        }
        if configuration.hasOptionModifier() {
            newlineOptions.append("Option+Enter")
        }
        
        let newline = newlineOptions.joined(separator: " or ")
        
        return (submit: submit, newline: newline.isEmpty ? "N/A" : newline)
    }
}