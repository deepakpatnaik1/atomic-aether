//
//  MessageRole.swift
//  atomic-aether
//
//  Role enumeration for LLM messages
//
//  ATOM 9: Models - Message role types
//
//  Atomic LEGO: Simple enum for message roles
//  Used across LLM services and conversation flow
//

import Foundation

enum MessageRole: String, Codable {
    case system = "system"
    case user = "user"
    case assistant = "assistant"
}