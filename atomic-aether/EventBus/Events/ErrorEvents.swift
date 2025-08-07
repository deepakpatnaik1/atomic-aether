//
//  ErrorEvents.swift
//  atomic-aether
//
//  Events for error reporting and handling
//
//  ATOM 2: ErrorBus - Error-related events
//
//  ATOMIC LEGO: Events fired by ErrorBus
//  Other atoms can subscribe to react to errors
//

import Foundation

// MARK: - Error Event Type

protocol ErrorEventType: AetherEvent {}

// MARK: - Error Events

enum ErrorEvents: ErrorEventType {
    case reported(error: Error, source: String, severity: ErrorSeverity)
    case dismissed
    case historyCleared
    case recoveryAttempted(error: Error, option: String)
    
    // MARK: - AetherEvent Conformance
    
    var source: String {
        switch self {
        case .reported(_, let source, _):
            return source
        default:
            return "ErrorBus"
        }
    }
}