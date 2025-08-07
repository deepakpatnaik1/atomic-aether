//
//  KeyboardConfiguration.swift
//  atomic-aether
//
//  Configuration for keyboard behavior
//
//  ATOM 12: Keyboard Behavior - Configuration model
//
//  Atomic LEGO: Pure data model for keyboard settings
//  Defines which keys trigger submit vs newline
//

import Foundation

struct KeyboardConfiguration: Codable {
    let submitKey: String
    let submitModifiers: [String]
    let newlineKey: String
    let newlineModifiers: [String]
    let enabled: Bool
    
    // UI Display strings
    let submitKeyDisplay: String
    let shiftKeyDisplay: String
    let optionKeyDisplay: String
    let noShortcutDisplay: String
    
    // Default configuration
    static let `default` = KeyboardConfiguration(
        submitKey: "return",
        submitModifiers: [],
        newlineKey: "return",
        newlineModifiers: ["shift", "option"],
        enabled: true,
        submitKeyDisplay: "Enter",
        shiftKeyDisplay: "Shift+Enter",
        optionKeyDisplay: "Option+Enter",
        noShortcutDisplay: "N/A"
    )
    
    // Check if a modifier is required for newline
    func requiresModifierForNewline() -> Bool {
        !newlineModifiers.isEmpty
    }
    
    // Check if modifiers contain shift
    func hasShiftModifier() -> Bool {
        newlineModifiers.contains("shift")
    }
    
    // Check if modifiers contain option
    func hasOptionModifier() -> Bool {
        newlineModifiers.contains("option")
    }
}