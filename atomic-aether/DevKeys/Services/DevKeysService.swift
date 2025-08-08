//
//  DevKeysService.swift
//  atomic-aether
//
//  Development-only API key storage using UserDefaults
//  No password prompts during development
//
//  ATOM: DevKeys - Developer-friendly API key storage
//

import Foundation
import SwiftUI

@MainActor
class DevKeysService: ObservableObject {
    @Published var isEnabled: Bool = false {
        didSet {
            if isEnabled != oldValue {
                eventBus?.publish(DevKeysEvent.modeChanged(enabled: isEnabled))
            }
        }
    }
    
    private var configuration: DevKeysConfiguration = .default
    private var configBus: ConfigBus?
    private var eventBus: EventBus?
    private var errorBus: ErrorBus?
    private var stateBus: StateBus?
    
    private let userDefaults = UserDefaults.standard
    
    init() {
        // Load enabled state from UserDefaults
        self.isEnabled = userDefaults.bool(forKey: "devkeys.enabled")
    }
    
    func setup(configBus: ConfigBus, eventBus: EventBus, errorBus: ErrorBus, stateBus: StateBus) {
        self.configBus = configBus
        self.eventBus = eventBus
        self.errorBus = errorBus
        self.stateBus = stateBus
        
        // Load configuration
        if let config = configBus.load("DevKeys", as: DevKeysConfiguration.self) {
            self.configuration = config
            
            // Auto-enable in debug mode if configured
            #if DEBUG
            if config.autoEnableInDebug && !hasEverBeenToggled() {
                enable()
                // Auto-migrate from Keychain on first run
                if !hasAnyKeys() {
                    migrateFromKeychain()
                }
            } else if isEnabled && !hasAnyKeys() {
                // One-time migration for users who have already toggled
                migrateFromKeychain()
            }
            #endif
        }
        
        // Share state via StateBus
        stateBus.set(StateKey<Bool>("devKeys.devModeEnabled"), value: isEnabled)
    }
    
    // MARK: - Public Methods
    
    func enable() {
        isEnabled = true
        userDefaults.set(true, forKey: "devkeys.enabled")
        userDefaults.set(true, forKey: "devkeys.hasBeenToggled")
        stateBus?.set(StateKey<Bool>("devKeys.devModeEnabled"), value: true)
    }
    
    func disable() {
        isEnabled = false
        userDefaults.set(false, forKey: "devkeys.enabled")
        userDefaults.set(true, forKey: "devkeys.hasBeenToggled")
        stateBus?.set(StateKey<Bool>("devKeys.devModeEnabled"), value: false)
        
        // Optionally clear dev keys when disabling
        if configuration.clearOnDisable {
            clearAll()
        }
    }
    
    func toggle() {
        if isEnabled {
            disable()
        } else {
            enable()
        }
    }
    
    // MARK: - Key Storage
    
    func save(key: DevKeyType, value: String) {
        let storageKey = "\(configuration.storagePrefix).\(key.rawValue)"
        userDefaults.set(value, forKey: storageKey)
        eventBus?.publish(DevKeysEvent.keySaved(type: key))
    }
    
    func retrieve(key: DevKeyType) -> String? {
        let storageKey = "\(configuration.storagePrefix).\(key.rawValue)"
        return userDefaults.string(forKey: storageKey)
    }
    
    func delete(key: DevKeyType) {
        let storageKey = "\(configuration.storagePrefix).\(key.rawValue)"
        userDefaults.removeObject(forKey: storageKey)
        eventBus?.publish(DevKeysEvent.keyDeleted(type: key))
    }
    
    func clearAll() {
        for key in DevKeyType.allCases {
            delete(key: key)
        }
        eventBus?.publish(DevKeysEvent.allKeysCleared)
    }
    
    func hasKey(key: DevKeyType) -> Bool {
        return retrieve(key: key) != nil
    }
    
    func getAllKeys() -> [DevKeyType: String] {
        var result: [DevKeyType: String] = [:]
        for key in DevKeyType.allCases {
            if let value = retrieve(key: key) {
                result[key] = value
            }
        }
        return result
    }
    
    // MARK: - Migration Support
    
    func migrateFromKeychain() {
        guard isEnabled else { 
            print("❌ DevKeys: Migration skipped - DevKeys not enabled")
            return 
        }
        
        var migrated = 0
        
        // Try to get keys from Keychain
        if let openAIKey = KeychainService.retrieve(key: .openAIKey) {
            save(key: .openAI, value: openAIKey)
            migrated += 1
        }
        
        if let anthropicKey = KeychainService.retrieve(key: .anthropicKey) {
            save(key: .anthropic, value: anthropicKey)
            migrated += 1
        }
        
        if let fireworksKey = KeychainService.retrieve(key: .fireworksKey) {
            save(key: .fireworks, value: fireworksKey)
            migrated += 1
        }
        
        if migrated > 0 {
            eventBus?.publish(DevKeysEvent.migratedFromKeychain(count: migrated))
        }
    }
    
    // MARK: - Private Methods
    
    private func hasEverBeenToggled() -> Bool {
        return userDefaults.bool(forKey: "devkeys.hasBeenToggled")
    }
    
    private func hasAnyKeys() -> Bool {
        return hasKey(key: .openAI) || hasKey(key: .anthropic) || hasKey(key: .fireworks)
    }
}

// MARK: - Supporting Types

enum DevKeyType: String, CaseIterable {
    case openAI = "openai"
    case anthropic = "anthropic"
    case fireworks = "fireworks"
    
    var keychainKey: KeychainService.KeychainKey {
        switch self {
        case .openAI: return .openAIKey
        case .anthropic: return .anthropicKey
        case .fireworks: return .fireworksKey
        }
    }
    
    var displayName: String {
        switch self {
        case .openAI: return "OpenAI"
        case .anthropic: return "Anthropic"
        case .fireworks: return "Fireworks"
        }
    }
}

// MARK: - State Keys

extension StateKey {
    static var devModeEnabled: StateKey<Bool> {
        StateKey<Bool>("devKeys.devModeEnabled")
    }
}