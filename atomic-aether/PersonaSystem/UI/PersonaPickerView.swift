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
            // Anthropic personas
            if !personaStateService.configuration.anthropicPersonas.isEmpty {
                Section(header: Label(
                    uiConfig.labels.anthropicSection,
                    systemImage: "brain"
                )) {
                    ForEach(personaStateService.configuration.anthropicPersonas) { persona in
                        personaButton(for: persona)
                    }
                }
            }
            
            // Non-Anthropic personas
            if !personaStateService.configuration.nonAnthropicPersonas.isEmpty {
                Section(header: Label(
                    uiConfig.labels.otherPersonasSection,
                    systemImage: "person.2"
                )) {
                    ForEach(personaStateService.configuration.nonAnthropicPersonas) { persona in
                        personaButton(for: persona)
                    }
                }
            }
        } label: {
            HStack(spacing: 4) {
                if let currentPersona = personaStateService.currentPersonaDefinition {
                    Text(currentPersona.displayName)
                        .font(.system(size: fontSize))
                        .foregroundColor(.white.opacity(opacity))
                } else {
                    Text("Select Persona")
                        .font(.system(size: fontSize))
                        .foregroundColor(.white.opacity(opacity * 0.6))
                }
                
                Image(systemName: "chevron.down")
                    .font(.system(size: fontSize * 0.8))
                    .foregroundColor(.white.opacity(opacity * 0.8))
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
            inputText = "\(persona.displayName) "
            
            // Restore focus to input bar
            focusState.wrappedValue = true
        }) {
            HStack {
                Text(persona.displayName)
                
                // Show checkmark for current persona
                if persona.id == personaStateService.currentPersona {
                    Spacer()
                    Image(systemName: "checkmark")
                        .font(.caption)
                }
            }
        }
    }
}