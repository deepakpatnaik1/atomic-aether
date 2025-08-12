//
//  JournalCommandConfiguration.swift
//  atomic-aether
//
//  Configuration for /journal command behavior
//
//  ATOM 304: JournalCommand - Configuration model
//

import Foundation

struct JournalCommandConfiguration: Codable {
    let trigger: String
    let expandToLines: Int
    let clearTextOnExpand: Bool
    
    static let `default` = JournalCommandConfiguration(
        trigger: "/journal",
        expandToLines: 42,
        clearTextOnExpand: true
    )
}