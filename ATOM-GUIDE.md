# Atomic-Aether Developer Guide

This guide covers practical development patterns for working with atomic-aether. For the philosophical foundation, see [BOSS-RULES.md](BOSS-RULES.md).

## Start Here: Understanding Atomic-Aether

If you're new to atomic-aether, here's what you need to know:

### The Foundation
**EventBus (ATOM 101)** is the nervous system. Every atom communicates through it. No atom knows about any other atom directly - they only know about events. This is what makes the Atomic LEGO architecture possible.

### Try This First
Want to see how easy atom removal is? Try removing PersonaPicker (ATOM 402):
1. Delete the `ATOM-402-PersonaPicker` folder
2. Remove `PersonaPickerView` from InputBar (one line)
3. That's it - the app still works perfectly

Users can still switch personas by typing the persona name. This demonstrates Boss Rule #4 (Easy Removal) in action.

### The Core Buses
- **EventBus**: How atoms communicate
- **ConfigBus**: How atoms get their settings
- **StateBus**: How atoms share state
- **ErrorBus**: How atoms report problems

Master these four buses and you understand 80% of the architecture.

### Quick Navigation
- Building a new atom? Jump to [Creating a New Atom](#creating-a-new-atom)
- Looking for patterns? See [Common Patterns](#common-patterns)
- Need bus syntax? Check [ATOM-REFERENCE.md](ATOM-REFERENCE.md)

## Folder Naming Convention

Every atom folder MUST follow this pattern:
```
ATOM-XXX-AtomName/
```

Where XXX is a three-digit number (with leading zeros).

Examples:
- `ATOM-101-EventBus/`
- `ATOM-202-LLMServices/`
- `ATOM-502-Scrollback/`

This naming ensures:
- Folders sort numerically in file explorers
- Atom numbers are immediately visible
- No confusion about atom identity
- Easy grep/search operations

## Creating a New Atom

Follow this template when adding a new atom to the system:

### 1. Choose Your Series
- **100s**: Infrastructure (buses, core services)
- **200s**: LLM/AI related functionality
- **300s**: User input and interaction
- **400s**: Personas and profiles
- **500s**: Conversations and messaging
- **600s**: Visual theme and appearance
- **700s**: Developer tools

### 2. Standard Folder Structure
```
ATOM-XXX-YourAtomName/
├── Core/
│   └── YourAtomCoordinator.swift    # Optional, only if coordination needed
├── Models/
│   └── YourAtomConfiguration.swift  # Configuration structure (required)
├── Services/
│   └── YourAtomService.swift        # Business logic
├── Events/
│   └── YourAtomEvents.swift         # Event definitions if publishing events
├── UI/
│   └── YourAtomView.swift           # SwiftUI views if needed
└── Wire/
    └── YourAtomWire.swift           # Integration documentation (REQUIRED)
```

### 3. Wire File Template
```swift
//
//  YourAtomWire.swift
//  atomic-aether
//
//  Integration documentation for YourAtom
//
//  ATOM XXX: YourAtom - Removal and integration instructions
//

/*
 REMOVAL INSTRUCTIONS:
 To remove YourAtom completely:
 1. Delete ATOM-XXX-YourAtomName folder
 2. Remove yourAtomService initialization from atomic_aetherApp.swift (line ~XXX)
 3. Remove yourAtomService environment object from atomic_aetherApp.swift (line ~XXX)
 4. [Additional specific removal steps]
 5. Delete aetherVault/Config/YourAtom.json
 
 WARNING: [Describe what breaks without this atom]
 
 INTEGRATION POINTS:
 - atomic_aetherApp.swift: [How it's initialized]
 - [Other atoms that use this]: [How they integrate]
 - ConfigBus: Loads YourAtom.json configuration
 - EventBus: [Events published/subscribed]
 
 CONFIGURATION:
 All settings in aetherVault/Config/YourAtom.json
 
 BEST PRACTICES:
 - [Specific usage guidelines]
 - [Common patterns]
 - [Things to avoid]
 */
```

### 4. Integration Checklist
- [ ] Create folder structure following the template
- [ ] Add configuration file to `aetherVault/Config/YourAtom.json`
- [ ] Wire into `atomic_aetherApp.swift` if needed
- [ ] Add to environment objects if it's a service
- [ ] Subscribe to necessary events via EventBus
- [ ] Publish your own events for others to consume
- [ ] Document removal instructions in Wire file
- [ ] Add atom to the registry in [ATOM-REFERENCE.md](ATOM-REFERENCE.md)
- [ ] Test that removal instructions actually work

### 5. Configuration File
Every atom must have a configuration file:
```json
// aetherVault/Config/YourAtom.json
{
  "enabled": true,
  "settings": {
    // Your configuration here
  }
}
```

## Common Patterns

### How Atoms Communicate

#### EventBus Pattern
Atoms never import each other directly. They communicate through events:

```swift
// Publishing an event
eventBus.publish(PersonaSwitchedEvent(
    fromPersona: previousPersona,
    toPersona: newPersona,
    source: "PersonaPicker"
))

// Subscribing to events
eventBus.subscribe(to: PersonaSwitchedEvent.self) { [weak self] event in
    // React to persona change
    self?.updateForNewPersona(event.toPersona)
}
.store(in: &cancellables)
```

#### Configuration Loading
Every atom loads its configuration from JSON:

```swift
let config = configBus.load(
    "YourAtomConfiguration", 
    as: YourConfiguration.self
) ?? .default
```

#### State Sharing
When atoms need to share state:

```swift
// Define type-safe key
extension StateKey {
    static let yourState = StateKey<YourType>("yourState")
}

// Set value
stateBus.set(.yourState, value: yourValue)

// Get value
let value = stateBus.get(.yourState) ?? defaultValue
```

#### Error Reporting
Consistent error handling across all atoms:

```swift
errorBus.report(
    message: "Failed to load configuration",
    from: "YourAtomService",
    severity: .error,
    error: underlyingError
)
```

### Common Integration Points

#### In atomic_aetherApp.swift
```swift
// 1. Create your service
let yourAtomService = YourAtomService()

// 2. Setup with buses
yourAtomService.setup(
    configBus: configBus,
    eventBus: eventBus,
    stateBus: stateBus
)

// 3. Add to environment
.environmentObject(yourAtomService)
```

#### In Your Views
```swift
// Access your service
@EnvironmentObject var yourAtomService: YourAtomService

// Access buses if needed
@EnvironmentObject var eventBus: EventBus
@EnvironmentObject var configBus: ConfigBus
```

### Event Patterns

#### Lifecycle Events
```swift
enum YourAtomEvent {
    case started
    case completed(result: YourResult)
    case failed(error: Error)
}
```

#### State Change Events
```swift
struct YourStateChangedEvent: AetherEvent {
    let oldValue: YourType
    let newValue: YourType
    let source: String
}
```

### Error Handling Pattern
Always report errors to ErrorBus:

```swift
do {
    try performOperation()
} catch {
    errorBus.report(
        message: "Failed to perform operation",
        from: "YourAtomService",
        severity: .error,
        error: error
    )
}
```

## Best Practices

1. **Single Responsibility**: Each atom does ONE thing well
2. **Configuration First**: Never hardcode values
3. **Event-Driven**: Use EventBus for all communication
4. **Document Removal**: Wire file must have clear removal steps
5. **Test Removal**: Actually try removing your atom
6. **No Direct Dependencies**: Atoms don't import each other
7. **Graceful Fallbacks**: Handle missing dependencies

## Next Steps

- See [ATOM-REFERENCE.md](ATOM-REFERENCE.md) for a complete list of atoms and quick bus reference
- Read [BOSS-RULES.md](BOSS-RULES.md) to understand the philosophy
- Browse existing atoms in the codebase to see patterns in action
- Start with a simple atom like PersonaPicker to understand the structure