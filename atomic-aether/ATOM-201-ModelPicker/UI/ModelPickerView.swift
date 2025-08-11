//
//  ModelPickerView.swift
//  atomic-aether
//
//  Interactive model picker menu component
//
//  ATOM 201: Model Picker - UI Component
//
//  Atomic LEGO: SwiftUI Menu component for model selection
//  Displays current model and dropdown with grouped options
//

import SwiftUI

struct ModelPickerView: View {
    @ObservedObject var modelPickerService: ModelPickerService
    @ObservedObject var modelDisplayService: ModelDisplayService
    @EnvironmentObject var configBus: ConfigBus
    @EnvironmentObject var eventBus: EventBus
    @EnvironmentObject var personaStateService: PersonaStateService
    let fontSize: CGFloat
    let opacity: Double
    let color: Color?
    var focusState: FocusState<Bool>.Binding
    
    @State private var configuration: ModelPickerConfiguration = .default
    
    var body: some View {
        Menu {
            ForEach(modelPickerService.modelGroups, id: \.provider) { group in
                if modelPickerService.configuration.showProviderHeaders {
                    Section(header: Text(group.provider.uppercased())
                        .font(.system(size: fontSize * (configuration.typography?.sectionHeader?.sizeMultiplier ?? 0.85), weight: .semibold))
                        .foregroundColor((color ?? .white).opacity(opacity * (configuration.typography?.sectionHeader?.opacityMultiplier ?? 0.7)))
                    ) {
                        modelItems(for: group)
                    }
                } else {
                    modelItems(for: group)
                }
            }
        } label: {
            HStack(spacing: 4) {
                Text(modelDisplayService.currentModelDisplay)
                    .font(.system(size: fontSize))
                    .foregroundColor((color ?? .white).opacity(opacity))
                
                Image(systemName: "chevron.down")
                    .font(.system(size: fontSize * modelPickerService.configuration.chevronSizeRatio))
                    .foregroundColor((color ?? .white).opacity(opacity * modelPickerService.configuration.chevronSizeRatio))
            }
        }
        .menuStyle(.borderlessButton)
        .menuIndicator(.hidden)
        .onAppear {
            if let config = configBus.load("ModelPicker", as: ModelPickerConfiguration.self) {
                configuration = config
            }
        }
    }
    
    @ViewBuilder
    private func modelItems(for group: ModelPickerService.ModelGroup) -> some View {
        ForEach(group.models, id: \.id) { model in
            Button(action: {
                if let switchedPersonaId = modelPickerService.selectModel(model.id) {
                    // If a persona was switched, get its display name and insert it
                    if let persona = personaStateService.configuration.persona(for: switchedPersonaId) {
                        // Load PersonaUI config to get the suffix
                        let uiConfig = configBus.load("PersonaUI", as: PersonaUIConfiguration.self) ?? .default
                        let suffix = uiConfig.inputBarLayout.insertedTextSuffix
                        eventBus.publish(InputEvent.insertText(
                            text: "\(persona.displayName)\(suffix)",
                            source: "ModelPicker"
                        ))
                    }
                }
                // Restore focus to input bar
                focusState.wrappedValue = true
            }) {
                HStack {
                    Text(model.displayName)
                        .font(.system(size: fontSize))
                    
                    if modelPickerService.configuration.showCheckmark && model.isSelected {
                        Spacer()
                        Image(systemName: configuration.menuItemLayout?.checkmarkIcon ?? "checkmark")
                            .font(.caption)
                    }
                }
            }
        }
    }
}