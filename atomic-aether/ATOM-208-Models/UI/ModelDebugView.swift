//
//  ModelDebugView.swift
//  atomic-aether
//
//  Debug view for model registry
//
//  ATOM 208: Models - Debug UI component
//
//  Atomic LEGO: Optional debug view to inspect loaded models
//

import SwiftUI

struct ModelDebugView: View {
    @ObservedObject var modelRegistry: ModelRegistryService
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Model Registry Debug")
                .font(.headline)
            
            Text("Available Providers: \(modelRegistry.availableProviders.count)")
                .font(.subheadline)
            
            ForEach(modelRegistry.availableProviders, id: \.self) { provider in
                VStack(alignment: .leading, spacing: 4) {
                    Text("• \(provider.rawValue.capitalized)")
                        .fontWeight(.medium)
                    
                    let models = modelRegistry.availableModels(for: provider)
                    if !models.isEmpty {
                        ForEach(models, id: \.self) { model in
                            Text("  - \(model)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
        }
        .padding()
        .background(Color.black.opacity(0.8))
        .cornerRadius(8)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.white.opacity(0.2), lineWidth: 1)
        )
    }
}