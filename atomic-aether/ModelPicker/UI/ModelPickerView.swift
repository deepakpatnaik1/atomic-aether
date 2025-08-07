//
//  ModelPickerView.swift
//  atomic-aether
//
//  Interactive model picker menu component
//
//  ATOM 8: Model Picker - UI Component
//
//  Atomic LEGO: SwiftUI Menu component for model selection
//  Displays current model and dropdown with grouped options
//

import SwiftUI

struct ModelPickerView: View {
    @ObservedObject var modelPickerService: ModelPickerService
    @ObservedObject var modelDisplayService: ModelDisplayService
    let fontSize: CGFloat
    let opacity: Double
    var focusState: FocusState<Bool>.Binding
    
    var body: some View {
        Menu {
            ForEach(modelPickerService.modelGroups, id: \.provider) { group in
                if modelPickerService.configuration.showProviderHeaders {
                    Section(header: Label(
                        group.provider,
                        systemImage: modelPickerService.configuration.icon(for: group.provider.lowercased())
                    )) {
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
                    .foregroundColor(.white.opacity(opacity))
                
                Image(systemName: "chevron.down")
                    .font(.system(size: fontSize * modelPickerService.configuration.chevronSizeRatio))
                    .foregroundColor(.white.opacity(opacity * modelPickerService.configuration.chevronSizeRatio))
            }
        }
        .menuStyle(.borderlessButton)
        .menuIndicator(.hidden)
    }
    
    @ViewBuilder
    private func modelItems(for group: ModelPickerService.ModelGroup) -> some View {
        ForEach(group.models, id: \.id) { model in
            Button(action: {
                modelPickerService.selectModel(model.id)
                // Restore focus to input bar
                focusState.wrappedValue = true
            }) {
                HStack {
                    Text(model.displayName)
                    
                    if modelPickerService.configuration.showCheckmark && model.isSelected {
                        Spacer()
                        Image(systemName: "checkmark")
                            .font(.caption)
                    }
                }
            }
        }
    }
}