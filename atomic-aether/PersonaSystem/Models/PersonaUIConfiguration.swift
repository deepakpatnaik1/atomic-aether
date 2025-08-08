//
//  PersonaUIConfiguration.swift
//  atomic-aether
//
//  Configuration for persona UI strings
//
//  ATOM 10: Personas - UI configuration
//
//  Atomic LEGO: UI labels and tooltips configuration
//  Loaded from PersonaUI.json via ConfigBus
//

import Foundation

struct PersonaUIConfiguration: Codable {
    let labels: Labels
    let defaults: Defaults
    let fontMappings: [String: FontMapping]
    let weightMappings: [String: String]
    let styleMappings: [String: String]
    let tooltips: Tooltips
    let typography: Typography
    let selectedHighlight: SelectedHighlight
    let tableLayout: TableLayout
    let chevronIcon: ChevronIcon
    let inputBarLayout: InputBarLayout
    let menuItemLayout: MenuItemLayout
    let tableAlignment: TableAlignment
    let paddingRatios: PaddingRatios
    
    struct Labels: Codable {
        let customModelIndicator: String
        let anthropicSection: String
        let otherPersonasSection: String
        let functionalExpertsSection: String
        let cognitiveVoicesSection: String
        let selectPersonaPlaceholder: String
        let personaRoleSeparator: String
    }
    
    struct Defaults: Codable {
        let sizeMultiplier: Double
        let opacityMultiplier: Double
        let backgroundOpacity: Double
        let cornerRadius: Double
        let padding: Double
        let fallbackAlignment: String
    }
    
    struct FontMapping: Codable {
        let customFontName: String?
        let fallbackToSystem: Bool?
        let useSystemFont: Bool?
    }
    
    struct Tooltips: Codable {
        let currentPersona: String
        let talkingTo: String
    }
    
    struct Typography: Codable {
        let sectionHeader: FontConfig
        let personaName: FontConfig
        let personaRole: FontConfig
        let inputBarLabel: FontConfig
        
        struct FontConfig: Codable {
            let fontName: String        // "system", "Inter", "Menlo", etc.
            let weight: String          // "regular", "medium", "semibold", "bold"
            let sizeMultiplier: Double  // 1.0 = base size, 0.9 = 90% of base
            let opacityMultiplier: Double // 1.0 = base opacity
            let style: String?          // "normal", "smallCaps", nil
        }
    }
    
    struct SelectedHighlight: Codable {
        let backgroundColor: String  // Hex color for highlight
        let backgroundOpacity: Double
        let cornerRadius: Double
        let padding: Double
    }
    
    struct TableLayout: Codable {
        let spacing: Double
        let nameColumnMinWidth: Double
    }
    
    struct ChevronIcon: Codable {
        let symbolName: String
        let sizeMultiplier: Double
        let opacityMultiplier: Double
    }
    
    struct InputBarLayout: Codable {
        let labelSpacing: Double
        let placeholderOpacityMultiplier: Double
        let insertedTextSuffix: String
    }
    
    struct MenuItemLayout: Codable {
        let roleSpacing: String
        let checkmarkIcon: String
    }
    
    struct TableAlignment: Codable {
        let nameColumn: String  // "leading", "center", "trailing"
        let roleColumn: String  // "leading", "center", "trailing"
    }
    
    struct PaddingRatios: Codable {
        let verticalPaddingRatio: Double  // ratio of horizontal padding for vertical
    }
    
    // MARK: - Helper Methods
    
    func currentPersonaTooltip(for persona: String) -> String {
        tooltips.currentPersona.replacingOccurrences(of: "{persona}", with: persona)
    }
    
    func talkingToTooltip(for persona: String) -> String {
        tooltips.talkingTo.replacingOccurrences(of: "{persona}", with: persona)
    }
    
    // MARK: - Default Configuration
    
    static let `default` = PersonaUIConfiguration(
        labels: Labels(
            customModelIndicator: "",
            anthropicSection: "",
            otherPersonasSection: "",
            functionalExpertsSection: "",
            cognitiveVoicesSection: "",
            selectPersonaPlaceholder: "",
            personaRoleSeparator: ""
        ),
        defaults: Defaults(
            sizeMultiplier: 0.0,
            opacityMultiplier: 0.0,
            backgroundOpacity: 0.0,
            cornerRadius: 0.0,
            padding: 0.0,
            fallbackAlignment: ""
        ),
        fontMappings: [:],
        weightMappings: [:],
        styleMappings: [:],
        tooltips: Tooltips(
            currentPersona: "",
            talkingTo: ""
        ),
        typography: Typography(
            sectionHeader: Typography.FontConfig(
                fontName: "",
                weight: "",
                sizeMultiplier: 0.0,
                opacityMultiplier: 0.0,
                style: nil
            ),
            personaName: Typography.FontConfig(
                fontName: "",
                weight: "",
                sizeMultiplier: 0.0,
                opacityMultiplier: 0.0,
                style: nil
            ),
            personaRole: Typography.FontConfig(
                fontName: "",
                weight: "",
                sizeMultiplier: 0.0,
                opacityMultiplier: 0.0,
                style: nil
            ),
            inputBarLabel: Typography.FontConfig(
                fontName: "",
                weight: "",
                sizeMultiplier: 0.0,
                opacityMultiplier: 0.0,
                style: nil
            )
        ),
        selectedHighlight: SelectedHighlight(
            backgroundColor: "",
            backgroundOpacity: 0.0,
            cornerRadius: 0.0,
            padding: 0.0
        ),
        tableLayout: TableLayout(
            spacing: 0.0,
            nameColumnMinWidth: 0.0
        ),
        chevronIcon: ChevronIcon(
            symbolName: "",
            sizeMultiplier: 0.0,
            opacityMultiplier: 0.0
        ),
        inputBarLayout: InputBarLayout(
            labelSpacing: 0.0,
            placeholderOpacityMultiplier: 0.0,
            insertedTextSuffix: ""
        ),
        menuItemLayout: MenuItemLayout(
            roleSpacing: "",
            checkmarkIcon: ""
        ),
        tableAlignment: TableAlignment(
            nameColumn: "",
            roleColumn: ""
        ),
        paddingRatios: PaddingRatios(
            verticalPaddingRatio: 0.0
        )
    )
}