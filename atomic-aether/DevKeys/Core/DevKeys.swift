//
//  DevKeys.swift
//  atomic-aether
//
//  Core coordinator for DevKeys atom
//  Development-only API key storage
//

import Foundation

/*
 ATOM: DevKeys
 
 PURPOSE:
 Eliminates Keychain password prompts during development by storing
 API keys in UserDefaults. Only active in DEBUG builds by default.
 
 COMPONENTS:
 - DevKeysService: UserDefaults-based storage
 - DevKeysConfiguration: JSON configuration  
 - DevKeysToggleView: UI toggle component
 - DevKeysEvents: Event definitions
 
 ARCHITECTURE:
 Following the 7 Boss Rules:
 1. Swifty - Uses UserDefaults, @EnvironmentObject, ObservableObject
 2. Atomic LEGO - Self-contained with Models/Services/UI/Events
 3. Configuration-driven - All settings in DevKeys.json
 4. Easy removal - Delete folder + 4 wire points
 5. No damage - Optional enhancement to API key loading
 6. Occam's Razor - Simple UserDefaults storage
 7. Bus integration - ConfigBus, EventBus, StateBus, ErrorBus
 
 SECURITY NOTE:
 UserDefaults storage is NOT secure. This is intentionally
 insecure to avoid password prompts during development.
 NEVER use in production.
 */