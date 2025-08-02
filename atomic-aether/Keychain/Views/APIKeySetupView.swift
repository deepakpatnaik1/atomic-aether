//
//  APIKeySetupView.swift
//  atomic-aether
//
//  UI for setting up API keys in Keychain
//
//  ATOM 17: Keychain Storage - Setup UI
//
//  Atomic LEGO: Simple form for API key entry
//  Saves securely to Keychain
//

import SwiftUI

struct APIKeySetupView: View {
    @EnvironmentObject var envLoader: EnvLoader
    @State private var openAIKey = ""
    @State private var anthropicKey = ""
    @State private var fireworksKey = ""
    @State private var showSuccess = false
    
    var body: some View {
        VStack(spacing: 20) {
            Text("API Key Setup")
                .font(.title)
                .padding(.bottom)
            
            VStack(alignment: .leading, spacing: 15) {
                // OpenAI Key
                VStack(alignment: .leading, spacing: 5) {
                    Label("OpenAI API Key", systemImage: "key.fill")
                        .foregroundColor(.secondary)
                    SecureField("sk-...", text: $openAIKey)
                        .textFieldStyle(.roundedBorder)
                }
                
                // Anthropic Key
                VStack(alignment: .leading, spacing: 5) {
                    Label("Anthropic API Key", systemImage: "key.fill")
                        .foregroundColor(.secondary)
                    SecureField("sk-ant-...", text: $anthropicKey)
                        .textFieldStyle(.roundedBorder)
                }
                
                // Fireworks Key
                VStack(alignment: .leading, spacing: 5) {
                    Label("Fireworks API Key", systemImage: "key.fill")
                        .foregroundColor(.secondary)
                    SecureField("fw_...", text: $fireworksKey)
                        .textFieldStyle(.roundedBorder)
                }
            }
            .padding()
            
            // Save Button
            Button("Save to Keychain") {
                saveKeys()
            }
            .buttonStyle(.borderedProminent)
            .disabled(openAIKey.isEmpty && anthropicKey.isEmpty && fireworksKey.isEmpty)
            
            if showSuccess {
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                    Text("API keys saved securely!")
                        .foregroundColor(.green)
                }
                .padding(.top)
            }
            
            Spacer()
            
            // Info
            Text("Your API keys are stored securely in macOS Keychain.\nNo file permissions required.")
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
        .frame(width: 400, height: 400)
        .onAppear {
            loadExistingKeys()
        }
    }
    
    private func loadExistingKeys() {
        openAIKey = KeychainService.retrieve(key: .openAIKey) ?? ""
        anthropicKey = KeychainService.retrieve(key: .anthropicKey) ?? ""
        fireworksKey = KeychainService.retrieve(key: .fireworksKey) ?? ""
    }
    
    private func saveKeys() {
        var saved = false
        
        if !openAIKey.isEmpty {
            _ = KeychainService.save(key: .openAIKey, value: openAIKey)
            saved = true
        }
        
        if !anthropicKey.isEmpty {
            _ = KeychainService.save(key: .anthropicKey, value: anthropicKey)
            saved = true
        }
        
        if !fireworksKey.isEmpty {
            _ = KeychainService.save(key: .fireworksKey, value: fireworksKey)
            saved = true
        }
        
        if saved {
            // Reload environment
            envLoader.load()
            
            // Show success
            showSuccess = true
            
            // Hide success after 3 seconds
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                showSuccess = false
            }
        }
    }
}