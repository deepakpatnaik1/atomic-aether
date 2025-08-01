//
//  PersonaDetector.swift
//  atomic-aether
//
//  Detects persona triggers in messages
//
//  ATOM 13: Persona System - Message detection
//
//  Atomic LEGO: Focused service for persona detection
//  Separates detection logic from state management
//

import Foundation

@MainActor
final class PersonaDetector {
    
    // MARK: - Properties
    
    private let personaRegex: NSRegularExpression?
    private let validPersonas: Set<String>
    
    // MARK: - Result Type
    
    struct DetectionResult {
        let detectedPersona: String?
        let cleanedMessage: String
        let isExplicitSwitch: Bool
        
        var hasPersona: Bool {
            detectedPersona != nil
        }
    }
    
    // MARK: - Initialization
    
    init(configuration: PersonaSystemConfiguration) {
        self.personaRegex = configuration.triggerRegex
        self.validPersonas = Set(configuration.personas.keys.map { $0.lowercased() })
    }
    
    // MARK: - Detection Methods
    
    /// Detect persona in message using pattern matching
    func detectPersona(in message: String) -> DetectionResult {
        guard let regex = personaRegex else {
            return DetectionResult(
                detectedPersona: nil,
                cleanedMessage: message,
                isExplicitSwitch: false
            )
        }
        
        // Try to match the persona pattern
        if let match = regex.firstMatch(
            in: message,
            options: [],
            range: NSRange(message.startIndex..., in: message)
        ) {
            // Extract persona name
            if let personaRange = Range(match.range(at: 1), in: message),
               let contentRange = Range(match.range(at: 2), in: message) {
                
                let personaName = String(message[personaRange]).lowercased()
                let content = String(message[contentRange]).trimmingCharacters(in: .whitespaces)
                
                // Validate persona exists
                if validPersonas.contains(personaName) {
                    return DetectionResult(
                        detectedPersona: personaName,
                        cleanedMessage: content,
                        isExplicitSwitch: true
                    )
                }
            }
        }
        
        // Check for special queries
        if isPersonaQuery(message) {
            return DetectionResult(
                detectedPersona: nil,
                cleanedMessage: message,
                isExplicitSwitch: false
            )
        }
        
        // No persona detected
        return DetectionResult(
            detectedPersona: nil,
            cleanedMessage: message,
            isExplicitSwitch: false
        )
    }
    
    /// Check if message is asking about current persona
    func isPersonaQuery(_ message: String) -> Bool {
        let lowercased = message.lowercased()
        let queries = [
            "who am i talking to",
            "who is this",
            "which persona",
            "current persona",
            "who are you"
        ]
        
        return queries.contains { lowercased.contains($0) }
    }
    
    /// Extract all persona mentions from a message (for future use)
    func extractAllPersonaMentions(from message: String) -> [String] {
        let words = message.split(separator: " ").map { $0.lowercased() }
        return words.filter { validPersonas.contains(String($0)) }
    }
    
    // MARK: - Validation
    
    /// Check if a string is a valid persona name
    func isValidPersona(_ name: String) -> Bool {
        validPersonas.contains(name.lowercased())
    }
    
    /// Get suggestions for misspelled persona names
    func suggestPersona(for input: String) -> String? {
        let lowercased = input.lowercased()
        
        // Find closest match using simple distance
        let matches = validPersonas.compactMap { persona -> (String, Int)? in
            let distance = levenshteinDistance(lowercased, persona)
            return distance <= 2 ? (persona, distance) : nil
        }
        
        return matches.min { $0.1 < $1.1 }?.0
    }
    
    // MARK: - Helper Methods
    
    /// Simple Levenshtein distance for typo detection
    private func levenshteinDistance(_ s1: String, _ s2: String) -> Int {
        let m = s1.count
        let n = s2.count
        
        if m == 0 { return n }
        if n == 0 { return m }
        
        var matrix = Array(repeating: Array(repeating: 0, count: n + 1), count: m + 1)
        
        for i in 0...m { matrix[i][0] = i }
        for j in 0...n { matrix[0][j] = j }
        
        for i in 1...m {
            for j in 1...n {
                let cost = s1[s1.index(s1.startIndex, offsetBy: i-1)] == 
                          s2[s2.index(s2.startIndex, offsetBy: j-1)] ? 0 : 1
                
                matrix[i][j] = min(
                    matrix[i-1][j] + 1,      // deletion
                    matrix[i][j-1] + 1,      // insertion
                    matrix[i-1][j-1] + cost  // substitution
                )
            }
        }
        
        return matrix[m][n]
    }
}