//
//  Environment.swift
//  atomic-aether
//
//  Model for environment configuration
//
//  ATOM 20: Environment Loader - API key storage
//
//  Atomic LEGO: Pure data model for environment variables
//  No logic, just holds API keys loaded from .env
//

import Foundation

struct Environment {
    let openAIKey: String?
    let anthropicKey: String?
    let fireworksKey: String?
    
    /// Check if we have at least one API key configured
    var hasAnyKey: Bool {
        openAIKey != nil || anthropicKey != nil || fireworksKey != nil
    }
}