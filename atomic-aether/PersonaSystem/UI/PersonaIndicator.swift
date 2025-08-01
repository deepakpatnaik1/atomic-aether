//
//  PersonaIndicator.swift
//  atomic-aether
//
//  Shows current persona in the UI
//
//  ATOM 13: Persona System - Visual indicator
//
//  Atomic LEGO: UI component showing active persona
//  Updates reactively when persona changes
//

import SwiftUI

struct PersonaIndicator: View {
    @EnvironmentObject var personaStateService: PersonaStateService
    @EnvironmentObject var modelStateService: ModelStateService
    @EnvironmentObject var themeService: ThemeService
    
    @State private var isHovering = false
    
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
                        Text("Custom")
                            .font(.caption2)
                            .foregroundColor(themeService.current.secondaryTextColor)
                    }
                } else {
                    if modelStateService.currentNonAnthropicModel != nil {
                        Text("•")
                            .foregroundColor(themeService.current.secondaryTextColor)
                        Text("Custom")
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
            .help("Current persona: \(persona.displayName)")
        }
    }
}

// MARK: - Compact Version

struct PersonaIndicatorCompact: View {
    @EnvironmentObject var personaStateService: PersonaStateService
    
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
            .help("Talking to: \(persona.displayName)")
        }
    }
}

// MARK: - Persona Switcher Menu

struct PersonaSwitcher: View {
    @EnvironmentObject var personaStateService: PersonaStateService
    @EnvironmentObject var themeService: ThemeService
    
    var body: some View {
        Menu {
            // Anthropic personas
            Section("Anthropic") {
                ForEach(personaStateService.configuration.anthropicPersonas) { persona in
                    Button(action: {
                        personaStateService.switchToPersona(persona.id)
                    }) {
                        Label(persona.displayName, systemImage: "person.circle")
                    }
                }
            }
            
            // Non-Anthropic personas
            Section("Other Personas") {
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