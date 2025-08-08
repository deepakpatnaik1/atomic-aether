//
//  DevKeysConfiguration.swift
//  atomic-aether
//
//  Configuration model for DevKeys atom
//

import Foundation

struct DevKeysConfiguration: Codable {
    let enabled: Bool
    let autoEnableInDebug: Bool
    let storagePrefix: String
    let warningMessage: String
    let toggleLabel: String
    let clearOnDisable: Bool
    let ui: UIConfiguration
    
    struct UIConfiguration: Codable {
        let showInRelease: Bool
        let warningColor: String
        let toggleDescription: String
        let sectionTitle: String
        let keySavedMessage: String
        let keysClearedMessage: String
    }
    
    static let `default` = DevKeysConfiguration(
        enabled: true,
        autoEnableInDebug: true,
        storagePrefix: "dev.apikeys",
        warningMessage: "⚠️ Dev mode active - keys stored insecurely",
        toggleLabel: "Development Mode",
        clearOnDisable: false,
        ui: UIConfiguration(
            showInRelease: false,
            warningColor: "#FF6B6B",
            toggleDescription: "Store API keys in UserDefaults (no password prompts)",
            sectionTitle: "Developer Options",
            keySavedMessage: "Key saved to dev storage",
            keysClearedMessage: "All dev keys cleared"
        )
    )
}