//
//  LLMEvents.swift
//  atomic-aether
//
//  Events for LLM interactions
//
//  ATOM 18: LLM Services - Event definitions
//  ATOM 5: EventBus - LLM event types
//
//  Atomic LEGO: Pure event definitions for LLM operations
//  Other atoms can subscribe to these events
//

import Foundation

enum LLMEvent: AetherEvent {
    case requestStarted(model: String, messageCount: Int, source: String)
    case tokenReceived(token: String, model: String, source: String)
    case responseCompleted(model: String, totalTokens: Int?, duration: TimeInterval, source: String)
    case errorOccurred(error: String, model: String, source: String)
    case streamingToggled(enabled: Bool, source: String)
    
    // MARK: - AetherEvent Conformance
    
    var source: String {
        switch self {
        case .requestStarted(_, _, let source),
             .tokenReceived(_, _, let source),
             .responseCompleted(_, _, _, let source),
             .errorOccurred(_, _, let source),
             .streamingToggled(_, let source):
            return source
        }
    }
}