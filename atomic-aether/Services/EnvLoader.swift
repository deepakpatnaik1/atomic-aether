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
//  1. Xcode scheme environment variables (for development)
//  2. Bundle resources (for distribution - no permissions needed)
//  3. App container Documents (user-provided fallback)
//

import Foundation
import SwiftUI

@MainActor
class EnvLoader: ObservableObject {
    @Published var environment: Environment?
    
    /// Load environment variables from .env file or process environment
    func load() {
        // Strategy 1: Try process environment variables (Xcode scheme)
        if loadFromProcessEnvironment() {
            return
        }
        
        // Strategy 2: Try bundle resources (packaged with app)
        if let bundleURL = Bundle.main.url(forResource: ".env", withExtension: nil) {
            if loadEnvFromPath(bundleURL) {
                return
            }
        }
        
        // Strategy 3: Try app's container Documents (if user placed it there)
        let containerDocs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
        if let docsURL = containerDocs?.appendingPathComponent(".env") {
            if loadEnvFromPath(docsURL) {
                return
            }
        }
        
        // Only print error if no environment found
        print("❌ No environment variables found. See ENVIRONMENT_SETUP.md for configuration instructions.")
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
}