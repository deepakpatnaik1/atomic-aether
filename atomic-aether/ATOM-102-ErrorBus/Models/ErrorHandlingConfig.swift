//
//  ErrorHandlingConfig.swift
//  atomic-aether
//
//  Configuration model for error handling behavior
//
//  ATOM 102: ErrorBus - Configuration model
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
    let showErrorCodes: Bool
    let toastPosition: String
    let toastWidth: CGFloat
    let animationDuration: TimeInterval
    let errorDomain: String
    
    /// Default configuration if JSON fails to load
    static let `default` = ErrorHandlingConfig(
        autoDismissInfo: true,
        infoDismissDelay: 2.0,
        autoDismissWarnings: true,
        warningDismissDelay: 3.0,
        maxErrorHistory: 50,
        showErrorCodes: false,
        toastPosition: "top",
        toastWidth: 400,
        animationDuration: 0.3,
        errorDomain: "AetherError"
    )
}