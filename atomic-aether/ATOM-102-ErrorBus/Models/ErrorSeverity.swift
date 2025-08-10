//
//  ErrorSeverity.swift
//  atomic-aether
//
//  Error severity levels for categorization
//
//  ATOM 102: ErrorBus - Error severity model
//
//  Atomic LEGO: Simple severity levels with display properties
//  Used for visual styling and behavior
//

import SwiftUI

enum ErrorSeverity: String, CaseIterable {
    case info
    case warning
    case error
    case critical
    
    /// Icon for this severity level
    var icon: String {
        switch self {
        case .info:
            return "info.circle"
        case .warning:
            return "exclamationmark.triangle"
        case .error:
            return "xmark.circle"
        case .critical:
            return "exclamationmark.octagon"
        }
    }
    
    /// Color for this severity level
    var color: Color {
        switch self {
        case .info:
            return .blue.opacity(0.9)
        case .warning:
            return .orange.opacity(0.9)
        case .error:
            return .red.opacity(0.9)
        case .critical:
            return .red
        }
    }
    
    /// Whether errors of this severity should auto-dismiss
    var shouldAutoDismiss: Bool {
        switch self {
        case .info, .warning:
            return true
        case .error, .critical:
            return false
        }
    }
}