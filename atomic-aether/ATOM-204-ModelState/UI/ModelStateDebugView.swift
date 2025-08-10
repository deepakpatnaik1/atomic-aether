//
//  ModelStateDebugView.swift
//  atomic-aether
//
//  Debug view for model state management
//
//  ATOM 204: Model State - Debug UI
//
//  Atomic LEGO: Optional debug view for testing
//  Shows current model state and allows testing
//

import SwiftUI

struct ModelStateDebugView: View {
    @EnvironmentObject var modelStateService: ModelStateService
    @EnvironmentObject var llmRouter: LLMRouter
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Model State Debug")
                .font(.title2)
                .bold()
            
            // Current State
            GroupBox("Current State") {
                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        Text("Default Anthropic:")
                        Text(modelStateService.currentDefaultAnthropicModel)
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Text("Default Non-Anthropic:")
                        Text(modelStateService.currentDefaultNonAnthropicModel)
                            .foregroundColor(.secondary)
                    }
                    
                    Divider()
                    
                    HStack {
                        Text("Override Anthropic:")
                        Text(modelStateService.currentAnthropicModel ?? "None")
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Text("Override Non-Anthropic:")
                        Text(modelStateService.currentNonAnthropicModel ?? "None")
                            .foregroundColor(.secondary)
                    }
                    
                    Divider()
                    
                    HStack {
                        Text("Current Model:")
                        Text(modelStateService.currentModel)
                            .foregroundColor(.blue)
                            .bold()
                    }
                }
                .padding()
            }
            
            // Available Models
            GroupBox("Available Models") {
                VStack(alignment: .leading, spacing: 10) {
                    Text("Anthropic Models:")
                        .font(.headline)
                    ForEach(modelStateService.availableModels(anthropic: true), id: \.self) { model in
                        Button(action: {
                            modelStateService.selectModel(model)
                        }) {
                            HStack {
                                Text(model)
                                Spacer()
                                if model == modelStateService.currentAnthropicModel {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(.green)
                                }
                            }
                        }
                        .buttonStyle(.plain)
                    }
                    
                    Divider()
                    
                    Text("Non-Anthropic Models:")
                        .font(.headline)
                    ForEach(modelStateService.availableModels(anthropic: false), id: \.self) { model in
                        Button(action: {
                            modelStateService.selectModel(model)
                        }) {
                            HStack {
                                Text(model)
                                Spacer()
                                if model == modelStateService.currentNonAnthropicModel {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(.green)
                                }
                            }
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding()
            }
            
            // Clear Buttons
            HStack {
                Button("Clear Anthropic Override") {
                    modelStateService.clearAnthropicOverride()
                }
                .disabled(modelStateService.currentAnthropicModel == nil)
                
                Button("Clear Non-Anthropic Override") {
                    modelStateService.clearNonAnthropicOverride()
                }
                .disabled(modelStateService.currentNonAnthropicModel == nil)
            }
            
            Spacer()
        }
        .padding()
        .frame(
            width: modelStateService.configuration.debugView.width,
            height: modelStateService.configuration.debugView.height
        )
    }
}