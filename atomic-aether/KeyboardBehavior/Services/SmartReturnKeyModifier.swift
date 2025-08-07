//
//  SmartReturnKeyModifier.swift
//  atomic-aether
//
//  Custom view modifier for smart enter key behavior
//
//  ATOM 12: Keyboard Behavior - View Modifier
//
//  Atomic LEGO: SwiftUI modifier for keyboard handling
//  Works around onKeyPress limitations
//

import SwiftUI
import AppKit

struct SmartReturnKeyModifier: ViewModifier {
    let keyboardService: KeyboardService
    let onSubmit: () -> Void
    
    func body(content: Content) -> some View {
        content
            .onKeyPress(.return) {
                // Check current event for modifiers
                if let event = NSApp.currentEvent {
                    let hasShift = event.modifierFlags.contains(.shift)
                    let hasOption = event.modifierFlags.contains(.option)
                    
                    // If no modifiers, submit
                    if !hasShift && !hasOption {
                        onSubmit()
                        return .handled
                    }
                }
                // Let TextEditor handle newline
                return .ignored
            }
    }
}

extension View {
    func smartReturnKey(keyboardService: KeyboardService, onSubmit: @escaping () -> Void) -> some View {
        self.modifier(SmartReturnKeyModifier(keyboardService: keyboardService, onSubmit: onSubmit))
    }
}