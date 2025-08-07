//
//  InputEvents.swift
//  atomic-aether
//
//  Events related to user input
//
//  ATOM 1: EventBus - Input event definitions
//
//  ATOMIC LEGO: Pure input event definitions
//  - Text submission, keyboard, file drops
//  - No business logic, just data carriers
//

import Foundation
import SwiftUI

// MARK: - Input Events

enum InputEvent: InputEventType {
    case textChanged(text: String, source: String)
    case textSubmitted(text: String, source: String)
    case keyPressed(key: KeyEquivalent, modifiers: EventModifiers, source: String)
    case fileDropped(files: [DroppedFileData], source: String)
    case filePasted(data: Data, type: String, source: String)
    case slashCommandEntered(command: String, source: String)
    case focusChanged(isFocused: Bool, source: String)
    
    // MARK: - AetherEvent Conformance
    
    var source: String {
        switch self {
        case .textChanged(_, let source),
             .textSubmitted(_, let source),
             .keyPressed(_, _, let source),
             .fileDropped(_, let source),
             .filePasted(_, _, let source),
             .slashCommandEntered(_, let source),
             .focusChanged(_, let source):
            return source
        }
    }
}

// MARK: - Event Data Types

struct DroppedFileData {
    let url: URL
    let name: String
    let size: Int64
    let type: FileType
    
    enum FileType {
        case image
        case pdf
        case text
        case markdown
        case code
        case unknown
    }
}

// MARK: - Keyboard Event Data

struct EventModifiers: OptionSet {
    let rawValue: Int
    
    static let command = EventModifiers(rawValue: 1 << 0)
    static let option = EventModifiers(rawValue: 1 << 1)
    static let control = EventModifiers(rawValue: 1 << 2)
    static let shift = EventModifiers(rawValue: 1 << 3)
    
    // Convert from SwiftUI modifiers
    static func from(_ modifiers: SwiftUI.EventModifiers) -> EventModifiers {
        var result = EventModifiers()
        if modifiers.contains(.command) { result.insert(.command) }
        if modifiers.contains(.option) { result.insert(.option) }
        if modifiers.contains(.control) { result.insert(.control) }
        if modifiers.contains(.shift) { result.insert(.shift) }
        return result
    }
}