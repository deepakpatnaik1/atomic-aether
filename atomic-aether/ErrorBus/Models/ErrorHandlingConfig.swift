//
//  ErrorHandlingConfig.swift
//  atomic-aether
//
//  Configuration model for error handling behavior
//
//  ATOM 11: ErrorBus - Configuration model
//
//  Atomic LEGO: Decodable configuration for ErrorHandling.json
//

import Foundation

struct ErrorHandlingConfig: Codable {
    let autoDismissInfo: Bool
    let infoDismissDelay: TimeInterval
    let autoDismissWarnings: Bool
    let warningDismissDelay: TimeInterval
    let maxErrorHistory: Int
    let logLevel: String
    let showErrorCodes: Bool
    let enableErrorLogging: Bool
    let toastPosition: String
    let toastWidth: CGFloat
    let animationDuration: TimeInterval
    
    /// Default configuration if JSON fails to load
    static let `default` = ErrorHandlingConfig(
        autoDismissInfo: true,
        infoDismissDelay: 2.0,
        autoDismissWarnings: true,
        warningDismissDelay: 3.0,
        maxErrorHistory: 50,
        logLevel: "warning",
        showErrorCodes: false,
        enableErrorLogging: true,
        toastPosition: "top",
        toastWidth: 400,
        animationDuration: 0.3
    )
}