//
//  BossProfileConfiguration.swift
//  atomic-aether
//
//  Configuration for Boss Profile folder reading
//
//  ATOM 26: Boss Profile Service - Configuration model
//
//  Atomic LEGO: Defines how to read boss folder contents
//  All files in folder become part of system prompt
//

import Foundation

struct BossProfileConfiguration: Codable {
    let profilePath: String
    let includedExtensions: [String]
    let excludedFiles: [String]
    let fileSeparator: String
    let maxFileSizeKB: Int
    
    static let `default` = BossProfileConfiguration(
        profilePath: "~/Documents/aetherVault/boss/",
        includedExtensions: [".md", ".txt", ".markdown", ".text"],
        excludedFiles: [".DS_Store", ".gitignore"],
        fileSeparator: "\n\n=== {filename} ===\n\n",
        maxFileSizeKB: 100
    )
    
    /// Get the expanded profile URL
    var profileURL: URL? {
        let expanded = NSString(string: profilePath).expandingTildeInPath
        return URL(fileURLWithPath: expanded)
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