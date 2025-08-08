//
//  PersonaPickerView.swift
//  atomic-aether
//
//  Interactive persona picker menu component
//
//  ATOM 10: Personas - Picker UI Component
//
//  Atomic LEGO: SwiftUI Menu component for persona selection
//  Displays current persona and dropdown with grouped options
//  Matches ModelPickerView style exactly
//

import SwiftUI

struct PersonaPickerView: View {
    @EnvironmentObject var personaStateService: PersonaStateService
    @EnvironmentObject var configBus: ConfigBus
    @Binding var inputText: String
    
    let fontSize: CGFloat
    let opacity: Double
    var focusState: FocusState<Bool>.Binding
    
    @State private var uiConfig: PersonaUIConfiguration = .default
    
    var body: some View {
        Menu {
            // Functional Experts
            if !personaStateService.configuration.functionalExperts.isEmpty {
                Section(header: Text(uiConfig.labels.functionalExpertsSection.uppercased())
                    .font(font(from: uiConfig.typography.sectionHeader, baseSize: fontSize))
                    .foregroundColor(.white.opacity(opacity * uiConfig.typography.sectionHeader.opacityMultiplier))
                ) {
                    ForEach(personaStateService.configuration.functionalExperts) { persona in
                        personaButton(for: persona)
                    }
                }
            }
            
            // Cognitive Voices
            if !personaStateService.configuration.cognitiveVoices.isEmpty {
                Section(header: Text(uiConfig.labels.cognitiveVoicesSection.uppercased())
                    .font(font(from: uiConfig.typography.sectionHeader, baseSize: fontSize))
                    .foregroundColor(.white.opacity(opacity * uiConfig.typography.sectionHeader.opacityMultiplier))
                ) {
                    ForEach(personaStateService.configuration.cognitiveVoices) { persona in
                        personaButton(for: persona)
                    }
                }
            }
        } label: {
            HStack(spacing: CGFloat(uiConfig.inputBarLayout.labelSpacing)) {
                if let currentPersona = personaStateService.currentPersonaDefinition {
                    Text(currentPersona.displayName)
                        .font(.system(size: fontSize))
                        .foregroundColor(.white.opacity(opacity))
                } else {
                    Text(uiConfig.labels.selectPersonaPlaceholder)
                        .font(.system(size: fontSize))
                        .foregroundColor(.white.opacity(opacity * uiConfig.inputBarLayout.placeholderOpacityMultiplier))
                }
                
                if !uiConfig.chevronIcon.symbolName.isEmpty {
                    Image(systemName: uiConfig.chevronIcon.symbolName)
                        .font(.system(size: fontSize * CGFloat(uiConfig.chevronIcon.sizeMultiplier)))
                        .foregroundColor(.white.opacity(opacity * uiConfig.chevronIcon.opacityMultiplier))
                }
            }
        }
        .menuStyle(.borderlessButton)
        .menuIndicator(.hidden)
        .onAppear {
            if let config = configBus.load("PersonaUI", as: PersonaUIConfiguration.self) {
                uiConfig = config
            }
        }
    }
    
    @ViewBuilder
    private func personaButton(for persona: PersonaDefinition) -> some View {
        Button(action: {
            // Switch to the persona
            personaStateService.switchToPersona(persona.id)
            
            // Insert persona name into input with trailing space
            inputText = "\(persona.displayName)\(uiConfig.inputBarLayout.insertedTextSuffix)"
            
            // Restore focus to input bar
            focusState.wrappedValue = true
        }) {
            HStack {
                if let role = persona.role {
                    Text(persona.displayName)
                        .font(.system(size: fontSize))
                    + Text(uiConfig.menuItemLayout.roleSpacing)
                        .font(.system(size: fontSize))
                    + Text(role)
                        .font(font(from: uiConfig.typography.personaRole, baseSize: fontSize))
                        .foregroundColor(.white.opacity(opacity * uiConfig.typography.personaRole.opacityMultiplier))
                } else {
                    Text(persona.displayName)
                        .font(.system(size: fontSize))
                }
                
                Spacer()
                
                if persona.id == personaStateService.currentPersona {
                    Image(systemName: uiConfig.menuItemLayout.checkmarkIcon)
                        .font(.caption)
                }
            }
        }
    }
    
    // MARK: - Helper Methods
    
    private func font(from config: PersonaUIConfiguration.Typography.FontConfig, baseSize: CGFloat) -> Font {
        // Use defaults if multiplier is 0
        let sizeMultiplier = config.sizeMultiplier > 0 ? config.sizeMultiplier : (uiConfig.defaults.sizeMultiplier > 0 ? uiConfig.defaults.sizeMultiplier : uiConfig.defaults.sizeMultiplier)
        let size = baseSize * CGFloat(sizeMultiplier)
        
        // Create base font using font mappings
        let baseFont: Font
        if let fontMapping = uiConfig.fontMappings[config.fontName.lowercased()] {
            if fontMapping.useSystemFont == true {
                baseFont = Font.system(size: size)
            } else if let customName = fontMapping.customFontName {
                baseFont = Font.custom(customName, size: size)
            } else {
                baseFont = Font.system(size: size)
            }
        } else {
            // Fallback to system font if no mapping found
            baseFont = Font.system(size: size)
        }
        
        // Apply weight using weight mappings
        let weightedFont: Font
        if let weightName = uiConfig.weightMappings[config.weight.lowercased()] {
            switch weightName {
            case "regular":
                weightedFont = baseFont.weight(.regular)
            case "medium":
                weightedFont = baseFont.weight(.medium)
            case "semibold":
                weightedFont = baseFont.weight(.semibold)
            case "bold":
                weightedFont = baseFont.weight(.bold)
            default:
                weightedFont = baseFont
            }
        } else {
            weightedFont = baseFont
        }
        
        // Apply style using style mappings
        if let style = config.style,
           let styleName = uiConfig.styleMappings[style.lowercased()],
           styleName == "smallCaps" {
            return weightedFont.smallCaps()
        }
        
        return weightedFont
    }
    
    private func alignmentFromString(_ alignment: String) -> Alignment {
        switch alignment.lowercased() {
        case "leading":
            return .leading
        case "center":
            return .center
        case "trailing":
            return .trailing
        default:
            return alignmentFromString(uiConfig.defaults.fallbackAlignment)
        }
    }
}