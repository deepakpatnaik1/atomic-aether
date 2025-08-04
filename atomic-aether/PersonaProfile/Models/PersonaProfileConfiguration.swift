//
//  PersonaProfileConfiguration.swift
//  atomic-aether
//
//  Configuration for Persona Profile folder reading
//
//  ATOM 27: Persona Profile Service - Configuration model
//
//  Atomic LEGO: Defines how to read persona folders
//  Each persona gets additional context from their folder
//

import Foundation

struct PersonaProfileConfiguration: Codable {
    let personasPath: String
    let includedExtensions: [String]
    let excludedFiles: [String]
    let fileSeparator: String
    let maxFileSizeKB: Int
    
    static let `default` = PersonaProfileConfiguration(
        personasPath: "~/Documents/aetherVault/personas/",
        includedExtensions: [".md", ".txt", ".markdown", ".text"],
        excludedFiles: [".DS_Store", ".gitignore"],
        fileSeparator: "\n\n=== {filename} ===\n\n",
        maxFileSizeKB: 100
    )
    
    /// Get the expanded personas directory URL
    var personasURL: URL? {
        let expanded = NSString(string: personasPath).expandingTildeInPath
        return URL(fileURLWithPath: expanded)
    }
    
    /// Get URL for specific persona folder
    func urlForPersona(_ personaId: String) -> URL? {
        personasURL?.appendingPathComponent(personaId)
    }
    
    /// Check if a file should be included
    func shouldIncludeFile(_ url: URL) -> Bool {
        let filename = url.lastPathComponent
        
        // Check excluded files
        if excludedFiles.contains(filename) {
            return false
        }
        
        // Check file extension
        let ext = url.pathExtension.isEmpty ? "" : ".\(url.pathExtension)"
        return includedExtensions.contains(ext)
    }
}