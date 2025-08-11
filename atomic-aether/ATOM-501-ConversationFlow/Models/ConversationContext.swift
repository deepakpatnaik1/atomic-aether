//
//  ConversationContext.swift
//  atomic-aether
//
//  Context for ongoing conversations
//
//  ATOM 501: ConversationFlow - Context tracking
//
//  Atomic LEGO: Maintains conversation state
//  Tracks current persona, model, and history
//

import Foundation

struct ConversationContext: Codable {
    let sessionId: UUID
    let startTime: Date
    var currentPersona: String
    var currentModel: String
    var messageCount: Int
    var lastActivity: Date
    
    init(persona: String, model: String) {
        self.sessionId = UUID()
        self.startTime = Date()
        self.currentPersona = persona
        self.currentModel = model
        self.messageCount = 0
        self.lastActivity = Date()
    }
    
    init(sessionId: UUID, startTime: Date, currentPersona: String, currentModel: String, messageCount: Int, lastActivity: Date) {
        self.sessionId = sessionId
        self.startTime = startTime
        self.currentPersona = currentPersona
        self.currentModel = currentModel
        self.messageCount = messageCount
        self.lastActivity = lastActivity
    }
    
    mutating func recordActivity() {
        messageCount += 1
        lastActivity = Date()
    }
    
    var duration: TimeInterval {
        Date().timeIntervalSince(startTime)
    }
    
    func isActive(timeoutSeconds: Double) -> Bool {
        // Consider session active if last activity within timeout
        Date().timeIntervalSince(lastActivity) < timeoutSeconds
    }
}