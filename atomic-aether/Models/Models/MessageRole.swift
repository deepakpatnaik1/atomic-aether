//
//  MessageRole.swift
//  atomic-aether
//
//  Enumeration for message roles in LLM conversations
//
//  ATOM 9: Models - Message role types
//
//  Atomic LEGO: Simple enum for type-safe message roles
//  Raw string values match API expectations
//

import Foundation

enum MessageRole: String, Codable {
    case user = "user"
    case assistant = "assistant"
    case system = "system"
}