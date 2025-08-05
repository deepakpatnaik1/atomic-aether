//
//  EnvLoaderConfiguration.swift
//  atomic-aether
//
//  Configuration model for environment loader
//
//  ATOM 20: Environment Loader - Configuration model
//
//  Atomic LEGO: Configuration structure for EnvLoader
//  Loaded from EnvLoader.json via ConfigBus
//

import Foundation

struct EnvLoaderConfiguration: Codable {
    let envFileName: String           // Just the filename, not full path
    let searchPaths: [String]         // Relative paths to search
    let apiKeyNames: APIKeyNames
    let parsing: ParsingConfiguration
    let errorMessages: ErrorMessages
    
    struct APIKeyNames: Codable {
        let openAI: String
        let anthropic: String
        let fireworks: String
    }
    
    struct ParsingConfiguration: Codable {
        let commentPrefix: String
        let quoteCharacters: String
    }
    
    struct ErrorMessages: Codable {
        let noKeysFound: String
    }
    
    // MARK: - Default Configuration
    
    static let `default` = EnvLoaderConfiguration(
        envFileName: ".env",
        searchPaths: [".", "..", "../..", "../../.."],
        apiKeyNames: APIKeyNames(
            openAI: "OPENAI_API_KEY",
            anthropic: "ANTHROPIC_API_KEY",
            fireworks: "FIREWORKS_API_KEY"
        ),
        parsing: ParsingConfiguration(
            commentPrefix: "#",
            quoteCharacters: "\"'"
        ),
        errorMessages: ErrorMessages(
            noKeysFound: "No API keys found. Please set up your API keys in the app."
        )
    )
}