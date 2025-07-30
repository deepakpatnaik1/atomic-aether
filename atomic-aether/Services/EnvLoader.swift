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

import Foundation
import SwiftUI

@MainActor
class EnvLoader: ObservableObject {
    @Published var environment: Environment?
    
    /// Load environment variables from .env file
    func load() {
        // Try project root first (for development)
        let projectRoot = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
        let envPath = projectRoot.appendingPathComponent(".env")
        
        do {
            let envContent = try String(contentsOf: envPath, encoding: .utf8)
            parseEnvironment(from: envContent)
            print("✅ Loaded environment from .env")
        } catch {
            print("❌ Failed to load .env file: \(error)")
            // Try bundle path as fallback
            if let bundlePath = Bundle.main.path(forResource: ".env", ofType: nil) {
                do {
                    let envContent = try String(contentsOfFile: bundlePath, encoding: .utf8)
                    parseEnvironment(from: envContent)
                    print("✅ Loaded environment from bundle")
                } catch {
                    print("❌ Failed to load .env from bundle: \(error)")
                }
            }
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
        
        // Log what we found (without exposing keys)
        if let env = environment {
            print("🔑 API Keys loaded:")
            if env.openAIKey != nil { print("  - OpenAI: ✅") }
            if env.anthropicKey != nil { print("  - Anthropic: ✅") }
            if env.fireworksKey != nil { print("  - Fireworks: ✅") }
        }
    }
}