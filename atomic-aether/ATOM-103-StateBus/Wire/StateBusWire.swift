//
//  StateBusWire.swift
//  atomic-aether
//
//  Integration documentation for StateBus
//
//  ATOM 103: StateBus - Removal and integration instructions
//

/*
 REMOVAL INSTRUCTIONS:
 To remove StateBus completely:
 1. Delete ATOM-103-StateBus folder
 2. Remove stateBus initialization from atomic_aetherApp.swift (line ~96)
 3. Remove stateBus environment object from atomic_aetherApp.swift (line ~197)
 4. Replace all stateBus.set() calls with local @State
 5. Replace all stateBus.get() calls with @Binding or direct properties
 
 WARNING: Without StateBus, atoms must pass state through props or direct dependencies.
 
 INTEGRATION POINTS:
 - atomic_aetherApp.swift: Creates and injects StateBus
 - ModelStateService: Stores model selection state
 - PersonaStateService: Stores persona selection state
 - DevKeysService: Stores dev mode preferences
 - ConfigBus: StateBus loads configuration for limits
 - EventBus: StateBus publishes StateValueChanged events
 
 STATE STORAGE API:
 ```swift
 // Define a type-safe key
 extension StateKey {
     static let currentPersona = StateKey<String>("currentPersona")
 }
 
 // Set a value
 stateBus.set(.currentPersona, value: "samara")
 
 // Get a value
 let persona: String? = stateBus.get(.currentPersona)
 
 // Get with default
 let persona = stateBus.get(.currentPersona) ?? "claude"
 ```
 
 COMMON STATE KEYS:
 - .currentPersona: String - Active persona ID
 - .currentAnthropicModel: String - Selected Anthropic model
 - .currentNonAnthropicModel: String - Selected non-Anthropic model
 - .modelSelectionHistory: [String] - Recent model selections
 - .lastPersonaInteraction: Date - Last persona switch time
 - .devModeEnabled: Bool - Developer mode state
 
 CONFIGURATION (StateBus.json):
 - maxStorageEntries: Maximum number of entries (FIFO eviction)
 - enableDebugLogging: Log all state changes
 - persistToDisk: Whether to persist state (future)
 
 BEST PRACTICES:
 - Always use type-safe StateKey<T> extensions
 - Keep state minimal - don't store computed values
 - Document what each key stores and who uses it
 - Consider if state really needs to be shared
 - Clean up state when no longer needed
 */