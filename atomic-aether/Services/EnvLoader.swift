//
//  EnvLoader.swift
//  atomic-aether
//
//  Service to load environment variables from .env file
//
//  ATOM 7: Environment Configuration - .env file loader
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
    
    /// Load environment variables from Keychain or fallback sources
    func load() {
        // Strategy 1: Try Keychain first (most secure)
        if loadFromKeychain() {
            return
        }
        
        // Strategy 2: Try process environment variables (Xcode scheme)
        if loadFromProcessEnvironment() {
            return
        }
        
        // Strategy 3: Try .env file for initial setup
        // First check root project directory
        let projectPath = URL(fileURLWithPath: "/Users/buda-air/Documents/code/atomic-aether/.env")
        if loadEnvFromPath(projectPath) {
            // If found, migrate to Keychain for future use
            migrateToKeychain()
            return
        }
        
        // Only print error if no environment found
        print("❌ No API keys found. Please set up your API keys in the app.")
    }
    
    /// Load from process environment (Xcode scheme variables)
    private func loadFromProcessEnvironment() -> Bool {
        let processInfo = ProcessInfo.processInfo
        let env = processInfo.environment
        
        let openAIKey = env["OPENAI_API_KEY"]
        let anthropicKey = env["ANTHROPIC_API_KEY"]
        let fireworksKey = env["FIREWORKS_API_KEY"]
        
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
            if trimmedLine.isEmpty || trimmedLine.hasPrefix("#") {
                continue
            }
            
            // Parse KEY=VALUE
            let parts = trimmedLine.split(separator: "=", maxSplits: 1)
            guard parts.count == 2 else { continue }
            
            let key = String(parts[0]).trimmingCharacters(in: .whitespaces)
            let value = String(parts[1]).trimmingCharacters(in: .whitespaces)
                .trimmingCharacters(in: CharacterSet(charactersIn: "\"'")) // Remove quotes
            
            switch key {
            case "OPENAI_API_KEY":
                openAIKey = value
            case "ANTHROPIC_API_KEY":
                anthropicKey = value
            case "FIREWORKS_API_KEY":
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
    }
}