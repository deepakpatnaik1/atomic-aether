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
    let expandToLines: Int
    let clearTextOnExpand: Bool
    let autoInsertPrefix: Bool
    let prefixTemplate: String
    let dateFormat: String
    let insertCursorPosition: InsertPosition
    let enableTimestamp: Bool
    let timestampFormat: String
    
    enum InsertPosition: String, Codable {
        case afterPrefix = "afterPrefix"
        case newLine = "newLine"
        case end = "end"
    }
    
    static let `default` = JournalCommandConfiguration(
        expandToLines: 34,
        clearTextOnExpand: true,
        autoInsertPrefix: true,
        prefixTemplate: "## Journal Entry",
        dateFormat: "EEEE, MMMM d, yyyy",
        insertCursorPosition: .newLine,
        enableTimestamp: true,
        timestampFormat: "HH:mm"
    )
}