//
//  ResponseParserEvents.swift
//  atomic-aether
//
//  Events published by response parser
//
//  ATOM 22: Response Parser - Event definitions
//
//  Atomic LEGO: Events for parsed response sections
//  Enables decoupled communication with other atoms
//

import Foundation

enum ResponseParserEvent: AetherEvent {
    case normalToken(String)                    // Stream directly to display
    case normalResponseComplete(content: String)
    case machineTrimComplete(content: String)   // May contain [INFERABLE] markers
    case fullyInferableResponse                 // Nothing to store
    case parsingError(Error)
    
    var source: String {
        "ResponseParserService"
    }
    
    var id: String {
        switch self {
        case .normalToken:
            return "response.parser.normal.token"
        case .normalResponseComplete:
            return "response.parser.normal.complete"
        case .machineTrimComplete:
            return "response.parser.trim.complete"
        case .fullyInferableResponse:
            return "response.parser.fully.inferable"
        case .parsingError:
            return "response.parser.error"
        }
    }
    
    var metadata: [String: Any] {
        switch self {
        case .normalToken(let token):
            return ["token": token]
        case .normalResponseComplete(let content):
            return ["content": content, "length": content.count]
        case .machineTrimComplete(let content):
            return ["content": content, "length": content.count]
        case .fullyInferableResponse:
            return ["stored": false]
        case .parsingError(let error):
            return ["error": error.localizedDescription]
        }
    }
}