//
//  PersonaFolderConfiguration.swift
//  atomic-aether
//
//  Configuration for dynamic persona folder watching
//
//  ATOM 10: Personas - Folder watcher configuration
//
//  Atomic LEGO: Settings for persona folder scanning
//  Hot-reloadable via ConfigBus
//

import Foundation

struct PersonaFolderConfiguration: Codable {
    let personasPath: String
    let watchInterval: TimeInterval
    let requiredFrontmatterFields: [String]
    let defaultColor: String
    let defaultAvatar: String
    let ignorePatterns: [String]
    
    static let `default` = PersonaFolderConfiguration(
        personasPath: "/Users/d.patnaik/code/atomic-aether/atomic-aether/aetherVault/Personas/",
        watchInterval: 1.0,
        requiredFrontmatterFields: ["name", "avatar", "color", "isAnthropic"],
        defaultColor: "#CCCCCC",
        defaultAvatar: "🤖",
        ignorePatterns: [".DS_Store", "*.tmp", ".*"]
    )
    
    // Helper to get expanded path
    var expandedPath: String {
        return (personasPath as NSString).expandingTildeInPath
    }
    
    // Check if a filename should be ignored
    func shouldIgnore(_ filename: String) -> Bool {
        for pattern in ignorePatterns {
            if pattern.hasPrefix("*") && pattern.count > 1 {
                let suffix = String(pattern.dropFirst())
                if filename.hasSuffix(suffix) { return true }
            } else if pattern.hasSuffix("*") && pattern.count > 1 {
                let prefix = String(pattern.dropLast())
                if filename.hasPrefix(prefix) { return true }
            } else if filename == pattern {
                return true
            }
        }
        return false
    }
}