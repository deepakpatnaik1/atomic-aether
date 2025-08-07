//
//  PersonaIndicator.swift
//  atomic-aether
//
//  Shows current persona in the UI
//
//  ATOM 10: Personas - Visual indicator
//
//  Atomic LEGO: UI component showing active persona
//  Updates reactively when persona changes
//

import SwiftUI

struct PersonaIndicator: View {
    @EnvironmentObject var personaStateService: PersonaStateService
    @EnvironmentObject var modelStateService: ModelStateService
    @EnvironmentObject var themeService: ThemeService
    @EnvironmentObject var configBus: ConfigBus
    
    @State private var isHovering = false
    @State private var uiConfig: PersonaUIConfiguration = .default
    
    var body: some View {
        if let persona = personaStateService.currentPersonaDefinition {
            HStack(spacing: 8) {
                // Persona icon/initial
                Circle()
                    .fill(persona.color)
                    .frame(width: 8, height: 8)
                
                // Persona name
                Text(persona.displayName)
                    .font(.system(.caption, design: .rounded))
                    .fontWeight(.medium)
                    .foregroundColor(themeService.current.primaryTextColor)
                
                // Model indicator (if manually selected)
                if personaStateService.isCurrentPersonaAnthropic {
                    if modelStateService.currentAnthropicModel != nil {
                        Text("•")
                            .foregroundColor(themeService.current.secondaryTextColor)
                        Text(uiConfig.labels.customModelIndicator)
                            .font(.caption2)
                            .foregroundColor(themeService.current.secondaryTextColor)
                    }
                } else {
                    if modelStateService.currentNonAnthropicModel != nil {
                        Text("•")
                            .foregroundColor(themeService.current.secondaryTextColor)
                        Text(uiConfig.labels.customModelIndicator)
                            .font(.caption2)
                            .foregroundColor(themeService.current.secondaryTextColor)
                    }
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(themeService.current.backgroundColor.opacity(0.9))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(persona.color.opacity(isHovering ? 0.6 : 0.3), lineWidth: 1)
                    )
            )
            .scaleEffect(isHovering ? 1.05 : 1.0)
            .onHover { hovering in
                withAnimation(.easeInOut(duration: 0.2)) {
                    isHovering = hovering
                }
            }
            .help(uiConfig.currentPersonaTooltip(for: persona.displayName))
            .onAppear {
                if let config = configBus.load("PersonaUI", as: PersonaUIConfiguration.self) {
                    uiConfig = config
                }
            }
        }
    }
}

// MARK: - Compact Version

struct PersonaIndicatorCompact: View {
    @EnvironmentObject var personaStateService: PersonaStateService
    @EnvironmentObject var configBus: ConfigBus
    
    @State private var uiConfig: PersonaUIConfiguration = .default
    
    var body: some View {
        if let persona = personaStateService.currentPersonaDefinition {
            HStack(spacing: 4) {
                Circle()
                    .fill(persona.color)
                    .frame(width: 6, height: 6)
                
                Text(persona.displayName)
                    .font(.caption2)
                    .fontWeight(.medium)
            }
            .help(uiConfig.talkingToTooltip(for: persona.displayName))
            .onAppear {
                if let config = configBus.load("PersonaUI", as: PersonaUIConfiguration.self) {
                    uiConfig = config
                }
            }
        }
    }
}

// MARK: - Persona Switcher Menu

struct PersonaSwitcher: View {
    @EnvironmentObject var personaStateService: PersonaStateService
    @EnvironmentObject var themeService: ThemeService
    @EnvironmentObject var configBus: ConfigBus
    
    @State private var uiConfig: PersonaUIConfiguration = .default
    
    var body: some View {
        Menu {
            // Anthropic personas
            Section(uiConfig.labels.anthropicSection) {
                ForEach(personaStateService.configuration.anthropicPersonas) { persona in
                    Button(action: {
                        personaStateService.switchToPersona(persona.id)
                    }) {
                        Label(persona.displayName, systemImage: "person.circle")
                    }
                }
            }
            
            // Non-Anthropic personas
            Section(uiConfig.labels.otherPersonasSection) {
                ForEach(personaStateService.configuration.nonAnthropicPersonas) { persona in
                    Button(action: {
                        personaStateService.switchToPersona(persona.id)
                    }) {
                        Label(persona.displayName, systemImage: "person.circle")
                    }
                }
            }
        } label: {
            PersonaIndicator()
                .contentShape(Rectangle())
        }
        .menuStyle(.borderlessButton)
        .menuIndicator(.hidden)
        .onAppear {
            if let config = configBus.load("PersonaUI", as: PersonaUIConfiguration.self) {
                uiConfig = config
            }
        }
    }
}

// MARK: - Preview

#Preview("Persona Indicator") {
    VStack(spacing: 20) {
        PersonaIndicator()
        PersonaIndicatorCompact()
        PersonaSwitcher()
    }
    .padding()
    .environmentObject(ThemeService())
}