//
//  SystemPromptManifestConfiguration.swift
//  atomic-aether
//
//  Configuration for system prompt manifest saving
//
//  ATOM 29: System Prompt Manifest - Configuration model
//
//  Atomic LEGO: Defines how to save system prompts for visibility
//  Provides transparency into what's sent to LLM
//

import Foundation

struct SystemPromptManifestConfiguration: Codable {
    let enabled: Bool
    let manifestPath: String
    let saveEveryPrompt: Bool
    let timestampFormat: String
    let includeMetadata: Bool
    let createPathIfMissing: Bool
    
    static let `default` = SystemPromptManifestConfiguration(
        enabled: true,
        manifestPath: "~/Documents/aetherVault/manifest/system-prompt.md",
        saveEveryPrompt: false,
        timestampFormat: "yyyy-MM-dd HH:mm:ss",
        includeMetadata: true,
        createPathIfMissing: true
    )
    
    /// Get the expanded manifest URL
    var manifestURL: URL? {
        let expanded = NSString(string: manifestPath).expandingTildeInPath
        return URL(fileURLWithPath: expanded)
    }
    
    /// Generate filename for timestamped saves
    func timestampedFilename(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd_HH-mm-ss"
        return "system-prompt-\(formatter.string(from: date)).md"
    }
}