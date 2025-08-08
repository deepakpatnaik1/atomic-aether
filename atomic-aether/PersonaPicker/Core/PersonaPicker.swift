//
//  PersonaPicker.swift
//  atomic-aether
//
//  Core coordinator for PersonaPicker atom
//
//  ATOM 31: PersonaPicker - Interactive persona selection menu
//
//  Atomic LEGO: Provides dropdown UI for switching between personas
//  Integrates with PersonaStateService for selection management
//

import SwiftUI

struct PersonaPicker {
    static let atomIdentifier = "PersonaPicker"
    static let atomVersion = "1.0.0"
    
    // MARK: - Atom Description
    // PersonaPicker provides an interactive dropdown menu for selecting personas.
    // It displays the current persona and allows switching between available personas
    // organized by categories (Functional Experts, Cognitive Voices).
    
    // MARK: - Dependencies
    // - PersonaStateService: For managing persona selection state
    // - ConfigBus: For loading UI configuration
    // - PersonaDefinition: Model from PersonaSystem atom
    
    // MARK: - Wire Points
    // 1. Add PersonaPickerView to InputBarView
    // 2. Pass required dependencies via environment
    // 3. Configure appearance via PersonaUI.json
    
    // MARK: - Removal Instructions
    // To remove this atom completely:
    // 1. Delete the PersonaPicker folder
    // 2. Remove PersonaPickerView from InputBarView (lines 74-80)
    // 3. Remove PersonaPickerConfiguration from PersonaUIConfiguration
    // 4. Remove menuItemLayout section from PersonaUI.json
    // The app will work perfectly without persona picker - users can still
    // switch personas by typing the persona name.
}