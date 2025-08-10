//
//  FrontmatterParser.swift
//  atomic-aether
//
//  Parses YAML frontmatter from markdown files
//
//  ATOM 401: Personas - Frontmatter parsing service
//
//  Atomic LEGO: Extracts metadata from persona markdown files
//  Handles YAML frontmatter between --- markers
//

import Foundation

public struct FrontmatterParser {
    public struct ParsedContent {
        public let frontmatter: [String: String]
        public let content: String
    }
    
    public static func parse(fileContent: String) -> ParsedContent? {
        let lines = fileContent.components(separatedBy: .newlines)
        
        // Check if file starts with ---
        guard lines.first?.trimmingCharacters(in: .whitespaces) == "---" else {
            // No frontmatter, return entire content
            return ParsedContent(frontmatter: [:], content: fileContent)
        }
        
        // Find the closing ---
        var frontmatterEndIndex = -1
        for (index, line) in lines.enumerated() {
            if index > 0 && line.trimmingCharacters(in: .whitespaces) == "---" {
                frontmatterEndIndex = index
                break
            }
        }
        
        guard frontmatterEndIndex > 0 else {
            // Invalid frontmatter format
            return nil
        }
        
        // Parse frontmatter
        var frontmatter: [String: String] = [:]
        for i in 1..<frontmatterEndIndex {
            let line = lines[i].trimmingCharacters(in: .whitespaces)
            if line.isEmpty { continue }
            
            // Split by first colon
            let parts = line.split(separator: ":", maxSplits: 1)
            guard parts.count == 2 else { continue }
            
            let key = parts[0].trimmingCharacters(in: .whitespaces)
            let value = parts[1].trimmingCharacters(in: .whitespaces)
            frontmatter[key] = value
        }
        
        // Get content after frontmatter
        let contentStartIndex = frontmatterEndIndex + 1
        let contentLines = Array(lines[contentStartIndex...])
        let content = contentLines.joined(separator: "\n").trimmingCharacters(in: .whitespacesAndNewlines)
        
        return ParsedContent(frontmatter: frontmatter, content: content)
    }
}