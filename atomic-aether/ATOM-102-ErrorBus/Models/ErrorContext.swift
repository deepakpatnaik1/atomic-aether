//
//  ErrorContext.swift
//  atomic-aether
//
//  Context information for errors
//
//  ATOM 102: ErrorBus - Error context model
//
//  Atomic LEGO: Metadata wrapper for errors
//  Provides additional context for debugging and display
//

import Foundation

struct ErrorContext: Identifiable, Equatable {
    let id = UUID()
    let error: Error
    let source: String
    let severity: ErrorSeverity
    let timestamp: Date
    let additionalInfo: [String: Any]?
    
    // MARK: - Equatable
    
    static func == (lhs: ErrorContext, rhs: ErrorContext) -> Bool {
        lhs.id == rhs.id
    }
    
    init(
        error: Error,
        source: String,
        severity: ErrorSeverity = .error,
        additionalInfo: [String: Any]? = nil
    ) {
        self.error = error
        self.source = source
        self.severity = severity
        self.timestamp = Date()
        self.additionalInfo = additionalInfo
    }
    
    /// User-friendly error message
    var message: String {
        if let localizedError = error as? LocalizedError {
            return localizedError.errorDescription ?? error.localizedDescription
        }
        return error.localizedDescription
    }
    
    /// Recovery suggestion if available
    var recoverySuggestion: String? {
        if let localizedError = error as? LocalizedError {
            return localizedError.recoverySuggestion
        }
        return nil
    }
    
    /// Whether this error has recovery actions
    var hasRecoveryOptions: Bool {
        if let _ = error as? RecoverableError {
            return true
        }
        return false
    }
}

// MARK: - Recoverable Error Protocol

protocol RecoverableError: Error {
    var recoveryOptions: [ErrorRecoveryOption] { get }
}

struct ErrorRecoveryOption {
    let title: String
    let action: () async -> Void
}