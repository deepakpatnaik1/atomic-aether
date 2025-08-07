//
//  EnvLoader.swift
//  atomic-aether
//
//  Service to load environment variables from .env file
//
//  ATOM 20: Environment Loader - .env file loader
//
//  Atomic LEGO: Single responsibility - read .env file
//  No dependencies, no hardcoding, easy to remove
//
//  Loading priority:
//  1. macOS Keychain (secure, no file access needed)
//  2. Xcode scheme environment variables (for development)
//  3. .env file fallback (first-time setup - auto-migrates to Keychain)
//

import Foundation
import SwiftUI

@MainActor
class EnvLoader: ObservableObject {
    @Published var environment: Environment?
    
    private var configuration: EnvLoaderConfiguration = .default
    private var configBus: ConfigBus?
    private var errorBus: ErrorBus?
    private var eventBus: EventBus?
    
    /// Setup with dependencies
    func setup(configBus: ConfigBus, errorBus: ErrorBus, eventBus: EventBus) {
        self.configBus = configBus
        self.errorBus = errorBus
        self.eventBus = eventBus
        
        // Load configuration
        if let config = configBus.load("EnvLoader", as: EnvLoaderConfiguration.self) {
            self.configuration = config
        }
    }
    
    /// Load environment variables from Keychain or fallback sources
    func load() {
        // Strategy 1: Try Keychain first (most secure)
        if loadFromKeychain() {
            eventBus?.publish(EnvLoaderEvent.environmentLoaded(hasKeys: environment?.hasAnyKey ?? false))
            return
        }
        
        // Strategy 2: Try process environment variables (Xcode scheme)
        if loadFromProcessEnvironment() {
            eventBus?.publish(EnvLoaderEvent.environmentLoaded(hasKeys: environment?.hasAnyKey ?? false))
            return
        }
        
        // Strategy 3: Try .env file for initial setup
        if searchForEnvFile() {
            // If found, migrate to Keychain for future use
            migrateToKeychain()
            eventBus?.publish(EnvLoaderEvent.environmentLoaded(hasKeys: environment?.hasAnyKey ?? false))
            return
        }
        
        // Report error if no environment found
        errorBus?.report(
            message: configuration.errorMessages.noKeysFound,
            from: "EnvLoader",
            severity: .warning
        )
        eventBus?.publish(EnvLoaderEvent.loadingFailed(reason: configuration.errorMessages.noKeysFound))
    }
    
    /// Load from process environment (Xcode scheme variables)
    private func loadFromProcessEnvironment() -> Bool {
        let processInfo = ProcessInfo.processInfo
        let env = processInfo.environment
        
        let openAIKey = env[configuration.apiKeyNames.openAI]
        let anthropicKey = env[configuration.apiKeyNames.anthropic]
        let fireworksKey = env[configuration.apiKeyNames.fireworks]
        
        // Check if we have at least one key
        if openAIKey != nil || anthropicKey != nil || fireworksKey != nil {
            environment = Environment(
                openAIKey: openAIKey,
                anthropicKey: anthropicKey,
                fireworksKey: fireworksKey
            )
            
            // Silent success - no logging needed
            
            return true
        }
        
        return false
    }
    
    /// Search for .env file in configured paths
    private func searchForEnvFile() -> Bool {
        let fileManager = FileManager.default
        let currentDirectory = fileManager.currentDirectoryPath
        
        for searchPath in configuration.searchPaths {
            let fullPath: String
            if searchPath == "." {
                fullPath = currentDirectory
            } else {
                fullPath = (currentDirectory as NSString).appendingPathComponent(searchPath)
            }
            
            let envPath = (fullPath as NSString).appendingPathComponent(configuration.envFileName)
            let envURL = URL(fileURLWithPath: envPath)
            
            if loadEnvFromPath(envURL) {
                return true
            }
        }
        
        return false
    }
    
    private func loadEnvFromPath(_ path: URL) -> Bool {
        do {
            let envContent = try String(contentsOf: path, encoding: .utf8)
            parseEnvironment(from: envContent)
            return true
        } catch {
            // Silent failure - it's expected during search
            return false
        }
    }
    
    private func parseEnvironment(from content: String) {
        var openAIKey: String?
        var anthropicKey: String?
        var fireworksKey: String?
        
        // Parse each line
        let lines = content.components(separatedBy: .newlines)
        for line in lines {
            // Skip empty lines and comments
            let trimmedLine = line.trimmingCharacters(in: .whitespaces)
            if trimmedLine.isEmpty || trimmedLine.hasPrefix(configuration.parsing.commentPrefix) {
                continue
            }
            
            // Parse KEY=VALUE
            let parts = trimmedLine.split(separator: "=", maxSplits: 1)
            guard parts.count == 2 else { continue }
            
            let key = String(parts[0]).trimmingCharacters(in: .whitespaces)
            let value = String(parts[1]).trimmingCharacters(in: .whitespaces)
                .trimmingCharacters(in: CharacterSet(charactersIn: configuration.parsing.quoteCharacters)) // Remove quotes
            
            switch key {
            case configuration.apiKeyNames.openAI:
                openAIKey = value
            case configuration.apiKeyNames.anthropic:
                anthropicKey = value
            case configuration.apiKeyNames.fireworks:
                fireworksKey = value
            default:
                // Ignore unknown keys
                break
            }
        }
        
        // Create environment
        environment = Environment(
            openAIKey: openAIKey,
            anthropicKey: anthropicKey,
            fireworksKey: fireworksKey
        )
        
        // Silent success - no logging needed
    }
    
    /// Load from Keychain
    private func loadFromKeychain() -> Bool {
        // Try batch retrieval first (single authentication)
        if let allKeys = KeychainService.retrieveAll() {
            let openAIKey = allKeys[.openAIKey]
            let anthropicKey = allKeys[.anthropicKey]
            let fireworksKey = allKeys[.fireworksKey]
            
            if openAIKey != nil || anthropicKey != nil || fireworksKey != nil {
                environment = Environment(
                    openAIKey: openAIKey,
                    anthropicKey: anthropicKey,
                    fireworksKey: fireworksKey
                )
                return true
            }
        }
        
        // Fallback to individual retrieval (backward compatibility)
        let openAIKey = KeychainService.retrieve(key: .openAIKey)
        let anthropicKey = KeychainService.retrieve(key: .anthropicKey)
        let fireworksKey = KeychainService.retrieve(key: .fireworksKey)
        
        // Check if we have at least one key
        if openAIKey != nil || anthropicKey != nil || fireworksKey != nil {
            environment = Environment(
                openAIKey: openAIKey,
                anthropicKey: anthropicKey,
                fireworksKey: fireworksKey
            )
            
            // Migrate to batch storage for next time
            var keysToSave: [KeychainService.KeychainKey: String] = [:]
            if let key = openAIKey { keysToSave[.openAIKey] = key }
            if let key = anthropicKey { keysToSave[.anthropicKey] = key }
            if let key = fireworksKey { keysToSave[.fireworksKey] = key }
            _ = KeychainService.saveAll(keysToSave)
            
            return true
        }
        
        return false
    }
    
    /// Migrate current environment to Keychain
    private func migrateToKeychain() {
        guard let env = environment else { return }
        
        // Collect all keys
        var keysToSave: [KeychainService.KeychainKey: String] = [:]
        if let key = env.openAIKey { keysToSave[.openAIKey] = key }
        if let key = env.anthropicKey { keysToSave[.anthropicKey] = key }
        if let key = env.fireworksKey { keysToSave[.fireworksKey] = key }
        
        // Save all at once (single authentication prompt)
        _ = KeychainService.saveAll(keysToSave)
        
        // Silent migration - keys saved to Keychain
        eventBus?.publish(EnvLoaderEvent.keychainMigrationCompleted)
    }
}