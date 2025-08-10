//
//  ErrorBus.swift
//  atomic-aether
//
//  Central error handling and reporting
//
//  ATOM 102: ErrorBus - Centralized error management
//
//  Atomic LEGO: Collects and manages errors from all atoms
//  - Publish errors for display
//  - Maintain error history
//  - Auto-dismiss based on configuration
//

import Foundation
import SwiftUI
import Combine

@MainActor
final class ErrorBus: ObservableObject {
    
    // MARK: - Published Properties
    
    @Published var currentError: ErrorContext?
    @Published var errorHistory: [ErrorContext] = []
    
    // MARK: - Dependencies
    
    private let configBus: ConfigBus
    private let eventBus: EventBus
    private var config: ErrorHandlingConfig = .default
    private var dismissTask: Task<Void, Never>?
    
    // MARK: - Initialization
    
    init(configBus: ConfigBus, eventBus: EventBus) {
        self.configBus = configBus
        self.eventBus = eventBus
        // Don't load configuration in init to avoid publishing during view updates
    }
    
    // MARK: - Configuration
    
    func setupConfiguration() {
        config = configBus.load("ErrorHandling", as: ErrorHandlingConfig.self) ?? .default
    }
    
    // MARK: - Error Reporting
    
    /// Report an error to the bus
    func report(
        _ error: Error,
        from source: String,
        severity: ErrorSeverity = .error,
        additionalInfo: [String: Any]? = nil
    ) {
        let context = ErrorContext(
            error: error,
            source: source,
            severity: severity,
            additionalInfo: additionalInfo
        )
        
        // Update current error
        currentError = context
        
        // Add to history
        errorHistory.append(context)
        trimHistory()
        
        // Publish event
        eventBus.publish(ErrorEvents.reported(
            error: error,
            source: source,
            severity: severity
        ))
        
        // Auto-dismiss if configured
        handleAutoDismiss(for: context)
    }
    
    /// Report with just a message
    func report(
        message: String,
        from source: String,
        severity: ErrorSeverity = .error
    ) {
        let error = NSError(
            domain: config.errorDomain,
            code: 0,
            userInfo: [NSLocalizedDescriptionKey: message]
        )
        report(error, from: source, severity: severity)
    }
    
    // MARK: - Error Dismissal
    
    /// Dismiss the current error
    func dismiss() {
        dismissTask?.cancel()
        dismissTask = nil
        currentError = nil
        eventBus.publish(ErrorEvents.dismissed)
    }
    
    /// Clear error history
    func clearHistory() {
        errorHistory.removeAll()
        eventBus.publish(ErrorEvents.historyCleared)
    }
    
    // MARK: - Private Methods
    
    private func handleAutoDismiss(for context: ErrorContext) {
        dismissTask?.cancel()
        
        let shouldAutoDismiss: Bool
        let dismissDelay: TimeInterval
        
        switch context.severity {
        case .info:
            shouldAutoDismiss = config.autoDismissInfo
            dismissDelay = config.infoDismissDelay
        case .warning:
            shouldAutoDismiss = config.autoDismissWarnings
            dismissDelay = config.warningDismissDelay
        case .error, .critical:
            shouldAutoDismiss = false
            dismissDelay = 0
        }
        
        if shouldAutoDismiss {
            dismissTask = Task {
                try? await Task.sleep(nanoseconds: UInt64(dismissDelay * 1_000_000_000))
                if !Task.isCancelled {
                    self.dismiss()
                }
            }
        }
    }
    
    private func trimHistory() {
        if errorHistory.count > config.maxErrorHistory {
            errorHistory = Array(errorHistory.suffix(config.maxErrorHistory))
        }
    }
    
    // MARK: - Convenience Methods
    
    /// Check if there's an active error
    var hasError: Bool {
        currentError != nil
    }
    
    /// Get errors from a specific source
    func errors(from source: String) -> [ErrorContext] {
        errorHistory.filter { $0.source == source }
    }
    
    /// Get errors of specific severity
    func errors(severity: ErrorSeverity) -> [ErrorContext] {
        errorHistory.filter { $0.severity == severity }
    }
}