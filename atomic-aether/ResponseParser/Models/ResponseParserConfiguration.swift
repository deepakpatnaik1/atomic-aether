//
//  ResponseParserConfiguration.swift
//  atomic-aether
//
//  Configuration for response parsing
//
//  ATOM 22: Response Parser - Configuration model
//
//  Atomic LEGO: All parsing markers externalized
//  Hot-reloadable via ConfigBus
//

import Foundation

struct ResponseParserConfiguration: Codable {
    let normalMarker: String              // "---NORMAL_RESPONSE---"
    let machineTrimMarker: String         // "---MACHINE_TRIM---"
    let inferableMarker: String           // "[INFERABLE"  (prefix to match variations)
    let inferableOnlyMarker: String       // "[INFERABLE - NOT STORED]"
    let bufferSize: Int
    
    static let `default` = ResponseParserConfiguration(
        normalMarker: "---NORMAL_RESPONSE---",
        machineTrimMarker: "---MACHINE_TRIM---",
        inferableMarker: "[INFERABLE",
        inferableOnlyMarker: "[INFERABLE - NOT STORED]",
        bufferSize: 1000
    )
}