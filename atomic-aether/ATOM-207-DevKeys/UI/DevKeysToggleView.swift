//
//  DevKeysToggleView.swift
//  atomic-aether
//
//  UI toggle for development mode API key storage
//

import SwiftUI

struct DevKeysToggleView: View {
    @EnvironmentObject var devKeysService: DevKeysService
    @EnvironmentObject var configBus: ConfigBus
    
    @State private var configuration: DevKeysConfiguration = .default
    
    var body: some View {
        // Only show in DEBUG builds unless configured otherwise
        #if DEBUG
        content
        #else
        if configuration.ui.showInRelease {
            content
        }
        #endif
    }
    
    private var content: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Section header
            Text(configuration.ui.sectionTitle)
                .font(.headline)
                .foregroundColor(Color.white.opacity(0.9))
            
            // Toggle row
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(configuration.toggleLabel)
                        .font(.system(size: 14))
                        .foregroundColor(.white)
                    
                    Text(configuration.ui.toggleDescription)
                        .font(.system(size: 12))
                        .foregroundColor(Color.white.opacity(0.6))
                }
                
                Spacer()
                
                Toggle("", isOn: Binding(
                    get: { devKeysService.isEnabled },
                    set: { newValue in
                        if newValue {
                            devKeysService.enable()
                        } else {
                            devKeysService.disable()
                        }
                    }
                ))
                .toggleStyle(SwitchToggleStyle())
                .labelsHidden()
            }
            .padding(.vertical, 8)
            
            // Warning message when enabled
            if devKeysService.isEnabled {
                HStack(spacing: 8) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.system(size: 14))
                        .foregroundColor(warningColor)
                    
                    Text(configuration.warningMessage)
                        .font(.system(size: 12))
                        .foregroundColor(warningColor)
                    
                    Spacer()
                }
                .padding(.vertical, 8)
                .padding(.horizontal, 12)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(warningColor.opacity(0.1))
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(warningColor.opacity(0.3), lineWidth: 1)
                        )
                )
            }
            
            // Migration button if keys exist in Keychain
            if devKeysService.isEnabled && hasKeychainKeys() {
                Button(action: {
                    devKeysService.migrateFromKeychain()
                }) {
                    HStack {
                        Image(systemName: "arrow.down.circle")
                            .font(.system(size: 14))
                        Text("Copy keys from Keychain")
                            .font(.system(size: 14))
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.white.opacity(0.1))
                    )
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .onAppear {
            loadConfiguration()
        }
    }
    
    private var warningColor: Color {
        Color(hex: configuration.ui.warningColor) ?? .red
    }
    
    private func loadConfiguration() {
        if let config = configBus.load("DevKeys", as: DevKeysConfiguration.self) {
            configuration = config
        }
    }
    
    private func hasKeychainKeys() -> Bool {
        return KeychainService.exists(key: .openAIKey) ||
               KeychainService.exists(key: .anthropicKey) ||
               KeychainService.exists(key: .fireworksKey)
    }
}

// MARK: - Color Extension

extension Color {
    init?(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            return nil
        }
        
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}