//
//  ConversationContext.swift
//  atomic-aether
//
//  Context for ongoing conversations
//
//  ATOM 15: Conversation Flow - Context tracking
//
//  Atomic LEGO: Maintains conversation state
//  Tracks current persona, model, and history
//

import Foundation

struct ConversationContext {
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