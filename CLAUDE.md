# The 7 Boss Rules for Software Development

These seven rules form the foundation of supernatural development velocity with bulletproof reliability. They are not suggestions - they are laws that govern every line of code, every architectural decision, and every feature implementation in the atomic-aether ecosystem.

## Rule 1: Swifty - Align with Swift's Natural Behavior

**The Principle**: Write Swift the way Swift wants to be written. Embrace the language's idioms, patterns, and safety features.

### What This Means in Practice

```swift
// ✅ SWIFTY: Uses @MainActor, async/await, proper optionals
@MainActor
final class EventBus: EventBusProtocol, ObservableObject {
    func asyncSubscribe<T: AetherEvent>(
        to eventType: T.Type
    ) -> AsyncStream<T> {
        AsyncStream { continuation in
            let cancellable = subscribe(to: eventType) { event in
                continuation.yield(event)
            }
            continuation.onTermination = { _ in
                cancellable.cancel()
            }
        }
    }
}

// ❌ NOT SWIFTY: Fighting the language
class BadEventBus {
    var events: NSMutableArray = NSMutableArray() // Using Objective-C types
    func getEvent(_ index: Int) -> Any! {         // Force unwrapping everywhere
        return events[index]
    }
}
```

### The Swifty Checklist
- **@MainActor** for UI-bound code
- **async/await** instead of completion handlers
- **Combine** for reactive patterns
- **ObservableObject** with @Published for SwiftUI
- **Proper optionals** - never force unwrap without certainty
- **Protocol-oriented** design over inheritance
- **Value types** (struct/enum) when possible
- **Generic constraints** for type safety

### Real Implementation
Every atom in atomic-aether follows Swifty patterns. The EventBus uses AsyncStream for modern concurrency. PersonaDetector returns value types. Services use @MainActor for thread safety. This isn't about being clever - it's about writing code that future Swift developers (including yourself) will instantly understand.

## Rule 2: Atomic LEGO - Composable Building Blocks

**The Principle**: Complex features are simple compositions of atomic components. Each atom has exactly ONE responsibility.

### The Atomic LEGO Formula

```
New Feature = New Model + New Service + New UI Component + Wire in Coordinator
```

### Perfect Atom Structure
```
PersonaSystem/
├── Core/           # Core coordinator
│   └── PersonaSystem.swift
├── Events/         # Event definitions  
│   └── PersonaEvents.swift
├── Models/         # Data structures
│   ├── PersonaDefinition.swift
│   └── PersonaConfiguration.swift
├── Services/       # Business logic
│   ├── PersonaDetector.swift
│   └── PersonaStateService.swift
├── UI/            # SwiftUI components
│   └── PersonaIndicator.swift
└── Wire/          # Integration documentation
    └── PersonaWire.swift
```

### Why This Works
- **Single Responsibility**: PersonaDetector ONLY detects personas
- **Clear Dependencies**: Each service declares exactly what it needs
- **Composability**: Voice Input + Personas = Voice-activated persona switching (automatically!)
- **Testing**: Test each atom in isolation

### Real Examples from Codebase
Adding voice input? Create VoiceAtom with VoiceMessage model, SpeechRecognitionService, VoiceInputButton. Wire it once in the coordinator. Now EVERY feature that accepts text automatically supports voice. No modifications to existing code needed.

## Rule 3: Configuration-Driven - Banish Hardcoding

**The Principle**: Every setting, string, color, size, URL, and magic number lives in configuration files.

### Configuration Excellence

```json
// aetherVault/Config/LLMProviders.json
{
  "providers": {
    "anthropic": {
      "baseURL": "https://api.anthropic.com/v1",
      "models": {
        "claude-sonnet-4": {
          "displayName": "Claude Sonnet 4",
          "maxTokens": 8192
        }
      }
    }
  }
}
```

```swift
// ✅ CONFIGURATION-DRIVEN
let config = configBus.load("LLMProviders", as: LLMConfiguration.self)
let url = config.providers["anthropic"]?.baseURL

// ❌ HARDCODED
let url = "https://api.anthropic.com/v1"  // Never do this!
```

### The Configuration Contract
- **Every atom** has a JSON configuration file
- **Hot-reload** in development via ConfigBus file watching
- **Type-safe** loading with Codable
- **Defaults** in aetherVault/Config/
- **No magic numbers** - even padding and opacity values

### Real Implementation
ConfigBus watches configuration files and publishes events when they change. During development, you can tweak InputBarAppearance.json and see changes instantly without recompiling. This isn't just convenience - it's about maintaining flexibility and preventing vendor lock-in.

## Rule 4: Easy Removal - Delete Without Fear

**The Principle**: If removing a feature is complicated, you built it wrong. Every atom must be deletable in under 5 steps.

### The Wire Contract

```swift
// KeyboardBehavior/Wire/KeyboardWire.swift
/*
 REMOVAL INSTRUCTIONS:
 To remove this atom completely:
 1. Delete the KeyboardBehavior folder
 2. Remove keyboardService from InputBarView line 45
 3. Replace .onKeyPress(.return) with .onSubmit on line 78  
 4. Delete aetherVault/Config/KeyboardBehavior.json
 
 That's it. The app will work perfectly without smart return key handling.
 */
```

### Removal Checklist
- **Document removal** in Wire file
- **List exact steps** with line numbers
- **Specify fallback** behavior
- **Maximum 5 steps** for complete removal
- **No cascading failures** after removal

### Real Examples
Want to remove the Journal feature? Delete the Journal folder and remove two wire points in the app initialization. Conversations continue working perfectly - they just aren't persisted. This isn't an accident - it's architectural discipline.

## Rule 5: No Damage - Harmony with Existing Features

**The Principle**: New features enhance, never break. Atoms communicate through events, never through direct coupling.

### Event-Based Harmony

```swift
// ✅ NO DAMAGE: Journal listens without coupling
private func subscribeToEvents() {
    eventBus?.subscribe(to: ResponseParserEvent.self) { [weak self] event in
        switch event {
        case .machineTrimComplete(let content):
            await self?.processMachineTrim(content)
        }
    }
    .store(in: &cancellables)
}

// ❌ DAMAGE: Direct coupling breaks modularity
class BadJournal {
    let parser: ResponseParser  // Direct dependency!
    func process() {
        let result = parser.parse()  // Tight coupling!
    }
}
```

### The Harmony Rules
- **No direct imports** between atoms (except shared protocols)
- **Event-based** communication only
- **Weak references** prevent retain cycles
- **Optional dependencies** with graceful fallbacks
- **No monkey patching** or swizzling

### Real Implementation
MessageStore doesn't know Journal exists. Journal subscribes to MessageAddedEvent and persists messages. Remove Journal? MessageStore continues working perfectly. Add SuperJournal? It also subscribes to the same event. Both work in harmony without knowing about each other.

## Rule 6: Occam's Razor - Don't Over-Engineer

**The Principle**: Build sophisticated, production-grade solutions without unnecessary complexity. The goal is elegance, not primitiveness.

### Production-Grade Without Over-Engineering

```swift
// ✅ OCCAM'S RAZOR: Production-ready async file handling
@MainActor
class SuperJournalService: ObservableObject {
    private var fileHandle: FileHandle?
    private let queue = DispatchQueue(label: "journal.write", qos: .background)
    
    func saveEntry(_ entry: SuperJournalEntry) async throws {
        try await withCheckedThrowingContinuation { continuation in
            queue.async { [weak self] in
                do {
                    guard let handle = self?.getOrCreateFileHandle() else { throw JournalError.handleCreationFailed }
                    let data = entry.formatted().data(using: .utf8)!
                    handle.seekToEndOfFile()
                    handle.write(data)
                    continuation.resume()
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }
    }
}

// ❌ OVER-ENGINEERED: Unnecessary abstraction layers
class OverEngineeredJournal {
    let persistenceStrategy: PersistenceStrategy
    let abstractFactory: AbstractJournalFactory  
    let repositoryPattern: RepositoryPattern<JournalEntity>
    let unitOfWork: UnitOfWork
    let domainEventDispatcher: DomainEventDispatcher
    // 15 more patterns when FileHandle would suffice...
}
```

### The Occam's Razor Test
- **Does this abstraction pay for itself?** Every layer must earn its complexity
- **Are we solving actual problems or hypothetical ones?** YAGNI (You Aren't Gonna Need It)
- **Can we achieve the same reliability with less machinery?** Prefer proven patterns
- **Is the sophistication serving the user or the developer's ego?** Stay humble
- **Would a senior engineer praise or question this approach?** Think peer review

### Real Production Examples
- **MessageStore**: Proper `@Published` array with `@MainActor` safety - sophisticated but not over-engineered
- **EventBus**: Full async/await support with `AsyncStream` - modern without being clever
- **ConfigBus**: Hot-reload with file watching - developer experience without complexity
- **LLMRouter**: Protocol-based routing with proper error handling - extensible without premature abstraction

### The Right Level of Sophistication

```swift
// ✅ SOPHISTICATED: Proper error handling, async support, type safety
class LLMRouter: ObservableObject {
    func route(_ request: LLMRequest) async throws -> AsyncThrowingStream<LLMResponse, Error> {
        guard let service = services[request.provider] else {
            throw LLMError.providerNotFound(request.provider)
        }
        
        return try await service.sendRequest(request)
    }
}

// ❌ PRIMITIVE: Would fail code review
func callLLM(_ text: String) -> String? {
    // Synchronous, no error handling, no type safety
    let result = makeAPICall(text)
    return result
}
```

### Production-Grade Checklist
- **Proper error handling** with typed errors
- **Async/await** for I/O operations  
- **Thread safety** with `@MainActor` or queues
- **Resource management** with defer/deinit
- **Monitoring hooks** for observability
- **Graceful degradation** for failures
- **Type safety** throughout

The goal: Code that would pass review at any top tech company, without the enterprise Java syndrome of 20 classes to read a file.

## Rule 7: Bus Integration - Use the Right Communication Channel

**The Principle**: Every atom connects to the system through the appropriate bus. Each bus has a specific purpose.

### The Five Buses

```swift
// ConfigBus: Load configuration
let config = configBus.load("Journal", as: JournalConfiguration.self)

// EventBus: Publish events others consume
eventBus.publish(JournalEvent.entryAdded(entry))

// StateBus: Share state across atoms
stateBus.setValue(currentPersona, for: StateKey.selectedPersona)

// ErrorBus: Handle errors centrally
errorBus.report(error, from: "JournalService", severity: .warning)

// PermissionBus: Check permissions (future)
// permissionBus.request(.fileAccess, for: journalPath)
```

### Bus Selection Guide
- **ConfigBus**: Settings, preferences, feature flags
- **EventBus**: Notifications, lifecycle events, user actions
- **StateBus**: Shared selections, UI state, temporary values
- **ErrorBus**: All error handling and user feedback
- **PermissionBus**: Security checks and access control (planned)

### Integration Rules
- **Only integrate buses you actually need**
- **Don't create event noise** - publish only what others consume
- **Use weak references** in closures
- **Clean up subscriptions** in deinit
- **Document bus dependencies** in your atom

### Real Implementation
EventBus has hot-reload configuration from ConfigBus. When config changes, it publishes to EventBus. Errors go to ErrorBus. This isn't about using all buses - it's about using the RIGHT buses for clear communication patterns.

## The Compound Effect

When all seven rules work together, magic happens:

1. **Swifty** code is naturally maintainable
2. **Atomic LEGO** makes features composable  
3. **Configuration** enables hot-reload and customization
4. **Easy removal** prevents technical debt
5. **No damage** ensures stability
6. **Occam's Razor** keeps everything debuggable
7. **Bus integration** provides clear communication

The result: **Supernatural development velocity with bulletproof reliability.**

## Usage Protocol

When implementing ANY feature:

1. **Check Swifty**: Is this idiomatic Swift?
2. **Design atomically**: What are the models, services, and UI?
3. **Externalize config**: What settings need JSON files?
4. **Document removal**: Write the Wire file
5. **Verify harmony**: Does this damage anything?
6. **Apply Occam**: Is there a simpler way?
7. **Connect buses**: Which buses are truly needed?

## The Promise

Follow these seven rules religiously, and you will:
- Ship features in hours, not weeks
- Debug issues in minutes, not days
- Onboard developers in hours, not months
- Maintain velocity as the codebase grows
- Sleep peacefully knowing nothing is fragile

These aren't just rules - they're the difference between software that ages like wine and software that rots like fruit.

---

*Remember: Every line of code is either following these rules or violating them. There is no middle ground.*

# Built Atoms

## Atom Numbering System

Atomic Aether uses a three-digit numbering system organized by functional series:

- **100 Series - Foundation Buses**: Core infrastructure for communication and configuration
- **200 Series - LLM Models**: Everything related to AI models and API keys
- **300 Series - Input System**: User input, commands, and keyboard handling
- **400 Series - Personas**: Complete persona ecosystem including profiles
- **500 Series - Conversations**: Message flow, display, and storage
- **600 Series - App Theme**: Visual design and theming system
- **700+ Series**: Reserved for future expansion

This system provides 99 slots per series, ensuring plenty of room for growth while maintaining clear organizational boundaries.

## 100 Series - Foundation Buses

### ATOM 101: EventBus
**Purpose**: The nervous system - pure pub/sub event routing  
**Dependencies**: ConfigBus (for hot-reload config)  
**Used by**: ALL atoms for communication  
**Wire**: Delete EventBus folder → atoms can't communicate but still function

### ATOM 102: ErrorBus
**Purpose**: Centralized error handling with toast notifications  
**Dependencies**: ConfigBus, EventBus  
**Used by**: All atoms for error reporting  
**Wire**: Delete ErrorBus folder → errors logged to console only

### ATOM 103: StateBus
**Purpose**: Shared state management across atoms  
**Dependencies**: ConfigBus, EventBus  
**Used by**: Atoms needing to share state  
**Wire**: Delete StateBus folder → atoms can't share state

### ATOM 104: ConfigBus
**Purpose**: JSON configuration loading with hot-reload  
**Dependencies**: EventBus (for change notifications)  
**Used by**: ALL atoms for configuration  
**Wire**: Delete ConfigBus folder → atoms use default values

## 200 Series - LLM Models

### ATOM 201: ModelPicker
**Purpose**: UI component for model selection  
**Dependencies**: ModelState, ConfigBus  
**Used by**: InputBar  
**Wire**: Delete ModelPicker folder → no model selection UI

### ATOM 202: LLMServices
**Purpose**: Provider implementations (Anthropic, OpenAI, Fireworks)  
**Dependencies**: Models, ConfigBus, EnvLoader  
**Used by**: ConversationFlow  
**Wire**: Delete LLMServices folder → no AI responses

### ATOM 203: ModelDisplay
**Purpose**: Visual indicators for active model  
**Dependencies**: ModelState, PersonaState, ConfigBus  
**Used by**: UI components  
**Wire**: Delete ModelDisplay folder → no model indicators

### ATOM 204: ModelState
**Purpose**: State management for selected models  
**Dependencies**: StateBus, ConfigBus, EventBus  
**Used by**: ModelPicker, ModelDisplay, ConversationFlow  
**Wire**: Delete ModelState folder → default models only

### ATOM 205: Keychain
**Purpose**: API key storage using macOS Keychain  
**Dependencies**: None (system service)  
**Used by**: EnvLoader  
**Wire**: Delete Keychain folder → falls back to env vars

### ATOM 206: EnvLoader
**Purpose**: Multi-source API key loading  
**Dependencies**: Keychain, DevKeys, ConfigBus  
**Used by**: LLMServices  
**Wire**: Delete EnvLoader folder → manual key entry required

### ATOM 207: DevKeys
**Purpose**: Development-only API key storage (no passwords)  
**Dependencies**: ConfigBus, EventBus  
**Used by**: EnvLoader  
**Wire**: Delete DevKeys folder → back to Keychain prompts

### ATOM 208: Models
**Purpose**: LLM model definitions and registry  
**Dependencies**: ConfigBus, EventBus  
**Used by**: LLMServices, ModelState, ModelPicker  
**Wire**: Delete Models folder → no model validation

## 300 Series - Input System

### ATOM 301: InputBar
**Purpose**: Text input with expandable TextEditor  
**Dependencies**: Multiple (see detailed docs)  
**Used by**: ContentView  
**Wire**: Delete InputBar folder → no user input

### ATOM 302: SlashCommandDetector
**Purpose**: Detects and processes slash commands  
**Dependencies**: ConfigBus, EventBus  
**Used by**: InputBar  
**Wire**: Delete SlashCommandDetector folder → no slash commands

### ATOM 303: KeyboardBehavior
**Purpose**: Smart return key handling  
**Dependencies**: ConfigBus  
**Used by**: InputBar  
**Wire**: Delete KeyboardBehavior folder → Enter = submit only

### ATOM 304: JournalCommand
**Purpose**: Enhanced /journal slash command  
**Dependencies**: ConfigBus, EventBus, StateBus  
**Used by**: Activated by SlashCommandDetector  
**Wire**: Delete JournalCommand folder → /journal just expands

## 400 Series - Personas

### ATOM 401: PersonaSystem
**Purpose**: Core persona detection and state management  
**Dependencies**: Multiple (see detailed docs)  
**Used by**: ConversationFlow, UI components  
**Wire**: Delete PersonaSystem folder → no personas

### ATOM 402: PersonaPicker
**Purpose**: UI component for persona selection  
**Dependencies**: PersonaState, ConfigBus  
**Used by**: InputBar  
**Wire**: Delete PersonaPicker folder → no persona UI

### ATOM 403: BossProfile
**Purpose**: User context loader (reads Boss folder)  
**Dependencies**: ConfigBus, EventBus  
**Used by**: SystemPromptBuilder  
**Wire**: Delete BossProfile folder → no user context

### ATOM 404: PersonaProfile
**Purpose**: Per-persona context loader  
**Dependencies**: ConfigBus, EventBus  
**Used by**: SystemPromptBuilder  
**Wire**: Delete PersonaProfile folder → base personas only

## 500 Series - Conversations

### ATOM 501: ConversationFlow
**Purpose**: Request orchestration and stream processing  
**Dependencies**: Multiple (see detailed docs)  
**Used by**: InputBar  
**Wire**: Delete ConversationFlow folder → no conversation handling

### ATOM 502: Scrollback
**Purpose**: Message display system  
**Dependencies**: MessageStore, ConfigBus  
**Used by**: ContentView  
**Wire**: Delete Scrollback folder → no message display

### ATOM 503: MessageStore
**Purpose**: Central message repository  
**Dependencies**: ConfigBus, EventBus  
**Used by**: Scrollback, ConversationFlow  
**Wire**: Delete MessageStore folder → no message storage

## 600 Series - App Theme

### ATOM 601: ThemeSystem
**Purpose**: Design tokens and theme service  
**Dependencies**: ConfigBus  
**Used by**: App root  
**Wire**: Delete ThemeSystem folder → default appearance

## Detailed Documentation

### ATOM 101: EventBus - The Nervous System

EventBus is the foundational communication layer that enables the Atomic LEGO architecture. It provides zero-coupling communication between all atoms through a pure publish/subscribe pattern.

#### Structure
```
ATOM-11-EventBus/
├── Core/
│   ├── EventBus.swift              # Main event router implementation
│   ├── EventBusProtocol.swift      # Protocol definition for testability
│   ├── Event.swift                 # Base event protocol
│   └── EventSubscription.swift     # Subscription management
├── Events/
│   ├── SystemEvents.swift          # App lifecycle events
│   ├── ConversationEvents.swift    # Message/conversation events
│   ├── InputEvents.swift           # User input events
│   └── NavigationEvents.swift      # Navigation/UI events
├── Models/
│   └── EventBusConfiguration.swift # Configuration model
└── Wire/
    └── EventBusWire.swift          # Integration documentation
```

#### Key Features
- **Zero Coupling**: Atoms don't know about each other, only events
- **Type-Safe Events**: Swift enums ensure compile-time safety
- **Async Support**: Modern `AsyncStream` for async/await patterns
- **Hot-Reload Config**: Debug mode and event history via ConfigBus
- **Weak References**: Prevents memory leaks in subscriptions
- **Multiple Event Types**: Can subscribe to multiple event types at once

#### Usage Example
```swift
// Publishing an event
eventBus.publish(PersonaSwitchedEvent(
    fromPersona: "claude",
    toPersona: "samara"
))

// Subscribing to events
eventBus.subscribe(to: PersonaSwitchedEvent.self) { event in
    print("Switched from \(event.fromPersona) to \(event.toPersona)")
}
.store(in: &cancellables)

// Async subscription
for await event in eventBus.asyncSubscribe(to: MessageAddedEvent.self) {
    await processMessage(event.message)
}
```

#### Configuration (EventBus.json)
```json
{
  "enableDebugMode": false,
  "maxEventHistory": 100,
  "eventHistoryEnabled": false
}
```

#### Why It's Essential
Without EventBus, every atom would need to directly import and depend on other atoms, creating a tangled web of dependencies. EventBus allows atoms to communicate through events without knowing who's listening or who's publishing, enabling true plug-and-play architecture.

#### Removal Instructions
```swift
// EventBusWire.swift
/*
 To remove EventBus completely:
 1. Delete ATOM-11-EventBus folder
 2. Remove eventBus from app initialization
 3. Remove all .publish() and .subscribe() calls
 4. Convert to direct method calls (breaks Atomic LEGO)
 
 WARNING: Without EventBus, atoms must directly couple to each other
 */
```

### ATOM 12: ErrorBus
**Purpose**: Centralized error handling with toast UI display  
**Dependencies**: EventBus, ConfigBus  
**Used by**: Most atoms for error reporting  
**Wire**: Delete ErrorBus folder → errors just don't display

### ATOM 12: ErrorBus - Centralized Error Handling

ErrorBus provides a unified error handling system that collects errors from all atoms and displays them as non-intrusive toast notifications. It ensures consistent error presentation while keeping error handling completely optional.

#### Structure
```
ATOM-12-ErrorBus/
├── Core/
│   └── ErrorBus.swift              # Main error handling service
├── Models/
│   ├── ErrorContext.swift          # Error context with metadata
│   ├── ErrorSeverity.swift         # Severity levels (info/warning/error/critical)
│   ├── ErrorHandlingConfig.swift   # Configuration model
│   └── AetherError.swift          # Custom error types
├── UI/
│   └── ErrorToast.swift           # Toast UI component and view modifier
└── Wire/
    └── ErrorBusWire.swift         # Integration documentation
```

#### Key Features
- **Centralized Collection**: Single point for all error reporting
- **Toast UI**: Non-blocking, auto-dismissing notifications
- **Severity Levels**: Different display times based on severity
- **Error History**: Tracks recent errors for debugging
- **Configuration**: Customizable dismiss times and appearance
- **Event Publishing**: Notifies when errors are reported/cleared

#### Usage Example
```swift
// Report an error
errorBus.report(
    message: "Failed to load persona configuration",
    from: "PersonaService",
    severity: .error,
    error: underlyingError  // Optional NSError
)

// Report with different severities
errorBus.report("Info message", from: "SomeService", severity: .info)
errorBus.report("Warning!", from: "AnotherService", severity: .warning)
errorBus.report("Critical failure", from: "CoreService", severity: .critical)

// Apply toast UI to view
ContentView()
    .errorToast()  // Shows error toasts
```

#### Configuration (ErrorHandling.json)
```json
{
  "autoDismissTimes": {
    "info": 3.0,
    "warning": 5.0,
    "error": 8.0,
    "critical": -1.0  // Never auto-dismiss
  },
  "maxVisibleErrors": 3,
  "toastPosition": "top",
  "animationDuration": 0.3
}
```

#### Error Severity Guidelines
- **`.info`**: Informational messages, quick dismiss (3s)
- **`.warning`**: Something unexpected but recoverable (5s)
- **`.error`**: Operation failed, user should know (8s)
- **`.critical`**: Requires user attention, manual dismiss

#### Why It's Essential
Without ErrorBus, every atom would need its own error UI, leading to:
- Inconsistent error presentation
- Duplicate error handling code
- Poor user experience with multiple error styles
- No central place to configure error behavior

ErrorBus provides a single, consistent way to handle errors while remaining completely optional.

#### Removal Instructions
```swift
// ErrorBusWire.swift
/*
 To remove ErrorBus completely:
 1. Delete ATOM-12-ErrorBus folder
 2. Remove errorBus from app initialization (line ~95)
 3. Remove errorBus environment object (line ~196)
 4. Remove .errorToast() from ContentView (line ~29)
 5. Remove all errorBus.report() calls
 
 The app continues working - errors are just silently ignored
 */
```

### ATOM 13: StateBus
**Purpose**: Type-safe key-value storage for shared state  
**Dependencies**: EventBus, ConfigBus  
**Used by**: ModelState, PersonaState, and pickers  
**Wire**: Delete StateBus folder → atoms can't share state but still function

### ATOM 13: StateBus - Type-Safe Shared State

StateBus provides a type-safe key-value store that allows atoms to share state without direct dependencies. Using strongly-typed keys prevents runtime errors and makes state access compile-time safe.

#### Structure
```
ATOM-13-StateBus/
├── Core/
│   └── StateBus.swift              # Main state storage service
├── Models/
│   ├── StateKey.swift              # Type-safe key definitions
│   ├── StateChange.swift           # State change event model
│   └── StateBusConfiguration.swift # Configuration model
├── Services/                       # Empty (for completeness)
├── UI/                            # Empty (for completeness)
└── Wire/
    └── StateBusWire.swift         # Integration documentation
```

#### Key Features
- **Type-Safe Keys**: Generic `StateKey<T>` ensures compile-time type safety
- **Shared State**: Atoms can share state without knowing about each other
- **Change Events**: Publishes events when state values change
- **FIFO Eviction**: Automatic cleanup when storage limit reached
- **Debug Logging**: Optional logging of all state changes
- **Reactive Updates**: Triggers objectWillChange for SwiftUI

#### Usage Example
```swift
// Define type-safe keys
extension StateKey {
    static let currentPersona = StateKey<String>("currentPersona")
    static let modelHistory = StateKey<[String]>("modelHistory")
    static let devModeEnabled = StateKey<Bool>("devModeEnabled")
}

// Set values
stateBus.set(.currentPersona, value: "samara")
stateBus.set(.modelHistory, value: ["gpt-4", "claude-3"])
stateBus.set(.devModeEnabled, value: true)

// Get values
let persona: String? = stateBus.get(.currentPersona)
let history = stateBus.get(.modelHistory) ?? []
let devMode = stateBus.get(.devModeEnabled) ?? false

// Listen for changes
eventBus.subscribe(to: StateValueChanged.self) { event in
    if event.key == "currentPersona" {
        print("Persona changed to: \(event.newValue ?? "nil")")
    }
}
```

#### Configuration (StateBus.json)
```json
{
  "maxStorageEntries": 100,
  "enableDebugLogging": false,
  "logStateChanges": false,
  "persistToDisk": false  // Future feature
}
```

#### Common State Keys
- **`.currentPersona`**: Currently active persona ID
- **`.currentAnthropicModel`**: Selected Anthropic model
- **`.currentNonAnthropicModel`**: Selected non-Anthropic model
- **`.modelSelectionHistory`**: Recent model selections
- **`.personaConversationHistory`**: Persona usage timestamps
- **`.devModeEnabled`**: Developer mode toggle

#### Why It's Essential
Without StateBus, atoms would need to:
- Pass state through complex prop drilling
- Create direct dependencies between atoms
- Use global singletons (anti-pattern)
- Duplicate state management logic

StateBus provides clean, type-safe state sharing while maintaining loose coupling.

#### Removal Instructions
```swift
// StateBusWire.swift
/*
 To remove StateBus completely:
 1. Delete ATOM-13-StateBus folder
 2. Remove stateBus from app initialization (line ~96)
 3. Remove stateBus environment object (line ~197)
 4. Replace stateBus.set() with local @State
 5. Replace stateBus.get() with @Binding or props
 
 Atoms must then pass state directly or use tight coupling
 */
```

### ATOM 14: ConfigBus
**Purpose**: JSON config loading with hot-reload  
**Dependencies**: EventBus (for change notifications)  
**Used by**: ALL atoms for configuration  
**Wire**: Delete ConfigBus folder → atoms use hardcoded defaults

### ATOM 14: ConfigBus - Configuration-Driven Development

ConfigBus loads JSON configuration files from the bundle and provides hot-reload capability during development. It's the foundation of Boss Rule #3 (Configuration-Driven), ensuring every setting lives in external files rather than hardcoded in source.

#### Structure
```
ATOM-14-ConfigBus/
├── Core/
│   └── ConfigBus.swift              # Configuration loader with file watching
├── Models/
│   └── ConfigBusConfiguration.swift # ConfigBus's own configuration
├── Events/
│   └── ConfigBusEvents.swift       # Configuration change events
├── Services/                       # Empty (for completeness)
├── UI/                            # Empty (for completeness)
└── Wire/
    └── ConfigBusWire.swift         # Integration documentation
```

#### Key Features
- **JSON Loading**: Type-safe loading with Codable
- **Hot-Reload**: File watching in development mode
- **Caching**: Configs loaded once and cached
- **Event Publishing**: Notifies when configs change
- **Bootstrap**: Can load its own configuration
- **Bundle Support**: Works with app bundle in production
- **Error Handling**: Graceful fallback to defaults

#### Usage Example
```swift
// Load a configuration
let personaConfig = configBus.load("Personas", as: PersonaConfiguration.self)

// Load with default fallback
let themeConfig = configBus.load("Theme", as: ThemeConfig.self) ?? .default

// Check if configuration exists
if configBus.hasConfiguration("FeatureFlags") {
    let flags = configBus.load("FeatureFlags", as: FeatureFlags.self)
}

// React to configuration changes
eventBus.subscribe(to: ConfigurationChangedEvent.self) { event in
    if event.configName == "InputBarAppearance" {
        // Reload UI settings
    }
}
```

#### Configuration Location
```
aetherVault/Config/
├── EventBus.json           # Event system settings
├── ErrorHandling.json      # Error display config
├── StateBus.json          # State storage limits
├── ConfigBus.json         # ConfigBus's own config
├── LLMProviders.json      # AI provider settings
├── Personas.json          # Persona definitions
├── InputBarAppearance.json # UI appearance
└── ... (one per atom)
```

#### Configuration (ConfigBus.json)
```json
{
  "enableHotReload": true,
  "fileExtension": ".json",
  "configDirectory": "Config",
  "cacheConfigurations": true,
  "publishChangeEvents": true
}
```

#### Hot-Reload Behavior
- **Development**: Watches files with DispatchSource
- **Production**: Loads once from bundle
- **File Changes**: Automatic reload and event publishing
- **Performance**: Minimal overhead with caching

#### Why It's Essential
Without ConfigBus:
- Every setting would be hardcoded
- Changes require recompilation
- No A/B testing capability
- No per-environment configuration
- Violates Boss Rule #3 completely

ConfigBus enables true configuration-driven development where behavior can be modified without touching code.

#### Removal Instructions
```swift
// ConfigBusWire.swift
/*
 To remove ConfigBus completely:
 1. Delete ATOM-14-ConfigBus folder
 2. Remove configBus initialization (line ~72)
 3. Remove configBus environment object (line ~190)
 4. Remove configBus assignment to eventBus (line ~76)
 5. Replace all configBus.load() with hardcoded values
 
 WARNING: Violates Boss Rule #3 - Configuration-Driven
 */
```

## Model/LLM System (20s)

### ATOM 21: Model Picker
**Purpose**: Dropdown menu UI for selecting AI models  
**Dependencies**: ModelState, EventBus  
**Used by**: InputBar  
**Wire**: Delete ModelPicker folder → remove from InputBar line 76

### ATOM 21: Model Picker - Interactive Model Selection UI

Model Picker provides a dropdown menu UI component for selecting AI models from different providers. It groups models by provider, shows visual indicators, and integrates with the model state system for persistence.

#### Structure
```
ATOM-21-ModelPicker/
├── Models/
│   └── ModelPickerConfiguration.swift # UI and behavior configuration
├── Services/
│   └── ModelPickerService.swift      # Selection logic and state management
├── UI/
│   └── ModelPickerView.swift         # SwiftUI Menu component
└── Wire/
    └── ModelPickerWire.swift         # Integration documentation
```

#### Key Features
- **Provider Grouping**: Models organized by provider (Anthropic, OpenAI, etc.)
- **Visual Indicators**: SF Symbol icons for each provider
- **Current Selection**: Checkmark shows active model
- **Auto-Persona Switching**: Optional persona switch on model change
- **Event Publishing**: Notifies system of model selection
- **Configuration-Driven**: All UI strings and behavior in JSON

#### Usage Example
```swift
// In InputBarView
HStack {
    Button("+", action: handleAddButton)
        .buttonStyle(.plain)
    
    ModelPickerView(
        modelPickerService: modelPickerService,
        selectedModel: $selectedModel,
        isExpanded: $isExpanded
    )
    .fixedSize()  // Prevents size jumps
    
    PersonaPickerView()
        .fixedSize()
}
```

#### Configuration (ModelPicker.json)
```json
{
  "providerOrder": ["anthropic", "openai", "fireworks"],
  "providerIcons": {
    "anthropic": "atom",
    "openai": "circle",
    "fireworks": "flame"
  },
  "displayNames": {
    "anthropic": "Anthropic",
    "openai": "OpenAI",
    "fireworks": "Fireworks"
  },
  "autoSwitchPersona": true,
  "insertPersonaName": true,
  "typography": {
    "sectionHeaderFont": "system",
    "sectionHeaderSize": 12,
    "itemFont": "system",
    "itemSize": 14
  }
}
```

#### Model Selection Flow
1. User clicks picker → Menu appears with grouped models
2. User selects model → ModelPickerService updates selection
3. Service calls ModelStateService.selectModel()
4. If autoSwitchPersona enabled → PersonaStateService switches
5. InsertTextEvent published → Persona name appears in input
6. ModelDisplayService updates → Shows new model name

#### Auto-Persona Switching
When `autoSwitchPersona` is enabled:
- Selecting Anthropic model → Switches to default Anthropic persona
- Selecting non-Anthropic model → Switches to default non-Anthropic persona
- Persona name inserted into input field for context

#### Why It's Essential
Without Model Picker:
- No UI for model selection
- Users stuck with default model
- No way to compare different AI providers
- Poor user experience

Model Picker provides clean, consistent model selection that integrates seamlessly with the state system.

#### Removal Instructions
```swift
// ModelPickerWire.swift
/*
 To remove ModelPicker completely:
 1. Delete ATOM-21-ModelPicker folder
 2. Remove modelPickerService initialization (line ~160)
 3. Remove modelPickerService environment object (line ~202)
 4. Remove ModelPickerView from InputBarView (line ~76)
 5. Remove modelPickerService @EnvironmentObject (line ~25)
 
 Users can no longer select models via UI
 */
```

### ATOM 22: LLM System
**Purpose**: Protocol-based LLM provider implementations with request/response models  
**Dependencies**: ConfigBus, EventBus, EnvLoader  
**Used by**: ConversationOrchestrator, ModelStateService  
**One-line**: Unified protocol for all AI providers with streaming responses

#### Why It Deserves to Be an Atom
The LLM System merges two closely related concepts (Models and LLM Services) into a single cohesive atom. It provides:
- Unified LLMService protocol for all providers
- Type-safe request/response models
- Streaming response support
- Model validation and registry
- Clean separation between data models and service implementations

#### Structure
```
ATOM-22-Models/
├── Core/                           # Empty (models are the core)
├── Models/
│   ├── LLMProvider.swift          # Provider enumeration
│   ├── LLMConfiguration.swift     # Configuration structures
│   ├── LLMRequest.swift          # Request model
│   ├── LLMResponse.swift         # Response and error models
│   └── MessageRole.swift         # Message role enum
├── Services/
│   └── ModelRegistryService.swift # Model validation service
├── Events/
│   └── ModelEvents.swift         # Model loading events
└── UI/
    └── ModelDebugView.swift      # Optional debug view

ATOM-22-LLMServices/
├── Protocols/
│   └── LLMService.swift          # Service protocol definition
├── Services/
│   ├── LLMRouter.swift           # Request router
│   ├── AnthropicService.swift    # Anthropic provider
│   ├── OpenAIService.swift       # OpenAI provider
│   └── FireworksService.swift    # Fireworks provider
└── Wire/
    └── LLMSystemWire.swift       # Integration documentation
```

#### Key Features
- **Protocol-Based**: All providers implement LLMService protocol
- **Streaming Responses**: AsyncThrowingStream for real-time tokens
- **Router Pattern**: LLMRouter selects provider based on request
- **Model Registry**: Validates model strings against configuration
- **Type-Safe Messages**: MessageRole enum for system/user/assistant
- **Error Handling**: Comprehensive error types and reporting
- **Configuration-Driven**: All endpoints and models in JSON

#### Usage Example
```swift
// Create a request
let request = LLMRequest(
    messages: [
        LLMMessage(role: .system, content: systemPrompt),
        LLMMessage(role: .user, content: userMessage)
    ],
    modelString: "anthropic/claude-3-5-sonnet",
    provider: .anthropic
)

// Route to appropriate service
let stream = try await llmRouter.route(request)

// Process streaming response
for try await response in stream {
    switch response {
    case .token(let token):
        // Append token to UI
    case .complete(let fullResponse):
        // Handle completion
    case .error(let error):
        // Report error
    }
}
```

#### Provider Configuration (LLMProviders.json)
```json
{
  "providers": {
    "anthropic": {
      "baseURL": "https://api.anthropic.com/v1",
      "models": {
        "claude-3-5-sonnet": {
          "apiName": "claude-3-5-sonnet-20241022",
          "displayName": "Claude 3.5 Sonnet",
          "maxTokens": 8192,
          "contextWindow": 200000
        }
      }
    },
    "openai": {
      "baseURL": "https://api.openai.com/v1",
      "models": {
        "gpt-4": {
          "apiName": "gpt-4-turbo-preview",
          "displayName": "GPT-4 Turbo",
          "maxTokens": 4096
        }
      }
    }
  }
}
```

#### API Key Loading Priority
1. **DevKeys** (development only) → UserDefaults
2. **Keychain** → Secure storage
3. **Process Environment** → Runtime variables
4. **.env File** → Development fallback

#### Adding New Providers
1. Add provider to LLMProvider enum
2. Create service implementing LLMService protocol
3. Register in LLMRouter.setupServices()
4. Add configuration to LLMProviders.json

#### Protocol Definition
```swift
protocol LLMService {
    var provider: LLMProvider { get }
    
    func sendRequest(_ request: LLMRequest) async throws -> AsyncThrowingStream<LLMResponse, Error>
    func validateModel(_ modelString: String) -> Bool
}
```

#### Why This Architecture
- **Flexibility**: Easy to add new providers
- **Consistency**: Same interface for all providers
- **Performance**: Streaming for better UX
- **Type Safety**: Enums and structs prevent errors
- **Testing**: Mock services can implement protocol

#### Removal Instructions
```swift
// LLMSystemWire.swift
/*
 To remove LLM System completely:
 1. Delete ATOM-22-LLMServices folder
 2. Delete ATOM-22-Models folder
 3. Remove llmRouter initialization (line ~109)
 4. Remove modelRegistry initialization (line ~102)
 5. Remove llmRouter environment object (line ~187)
 6. Remove llmRouter.setupServices() call (line ~219)
 7. Remove modelRegistry from dependencies
 8. Replace LLM calls with mock responses
 
 WARNING: No AI communication without this atom
 */
```

### ATOM 23: ModelDisplay
**Purpose**: Service that formats and displays the current model name  
**Dependencies**: ConfigBus, EventBus, ModelStateService, PersonaStateService  
**Used by**: InputBarView, ModelPickerView  
**One-line**: Formats raw model IDs into user-friendly display names

#### Why It Deserves to Be an Atom
ModelDisplay provides a single source of truth for how model names are displayed throughout the app. Without it, every UI component would need its own formatting logic, leading to inconsistency and duplication. It observes model changes from multiple sources and maintains the current display state.

#### Structure
```
ATOM-23-ModelDisplay/
├── Models/
│   └── ModelDisplayConfiguration.swift    # Display name mappings
├── Services/
│   └── ModelDisplayService.swift         # Formatting and state service
├── UI/
│   └── ModelIndicatorView.swift         # Reusable display component
└── Wire/
    └── ModelDisplayWire.swift           # Integration documentation
```

#### Key Features
- **Observer Pattern**: Watches PersonaStateService and ModelStateService
- **Configuration-Driven**: All display names in JSON
- **Formatting Hierarchy**: Custom names → short names → patterns → generic
- **Reusable Component**: ModelIndicatorView for consistent display
- **Event Listening**: Updates on PersonaSwitched and ModelSelected events
- **Smart Formatting**: Removes dates, capitalizes, handles separators
- **Provider Display**: Optional provider prefix with custom names

#### Usage Example
```swift
// In a view
ModelIndicatorView(
    modelDisplayService: modelDisplayService,
    fontSize: 12,
    opacity: 0.7
)

// Service automatically formats:
// "anthropic:claude-3-5-sonnet-20241022" → "Claude 3.5 Sonnet"
// "openai:gpt-4-turbo-preview" → "GPT-4 Turbo"
// "fireworks:llama-v3-70b-instruct" → "Llama V3 70B Instruct"
```

#### Configuration (ModelDisplay.json)
```json
{
  "modelDisplayNames": {
    "anthropic:claude-3-5-sonnet": "Claude 3.5 Sonnet",
    "openai:gpt-4": "GPT-4 Turbo"
  },
  "showProvider": false,
  "providerSeparator": " ",
  "providerDisplayNames": {
    "anthropic": "Anthropic",
    "openai": "OpenAI",
    "fireworks": "Fireworks"
  },
  "modelShortNames": {
    "gpt-4": "GPT-4",
    "claude-3-5-sonnet": "Claude 3.5 Sonnet",
    "llama-v3-70b": "Llama 3 70B"
  },
  "modelPatternReplacements": {
    "claude-3-5": "Claude 3.5",
    "gpt-": "GPT-",
    "-instruct": " Instruct"
  }
}
```

#### Display Priority
1. **Exact Match**: modelDisplayNames["anthropic:claude-3-5-sonnet"]
2. **Short Name**: modelShortNames["claude-3-5-sonnet"]
3. **Pattern Replace**: Replace patterns in model name
4. **Generic Format**: Capitalize words, remove dates

#### Integration Flow
```
PersonaStateService → currentPersona changes
                   ↓
ModelDisplayService → observes change
                   ↓
                   → gets model from PersonaStateService
                   → formats using configuration
                   → updates currentModelDisplay
                   ↓
ModelIndicatorView → displays formatted name
```

#### Why This Architecture
- **Single Responsibility**: Only handles display formatting
- **Reactive Updates**: Automatically updates when model changes
- **Configuration Control**: Marketing can update names without code changes
- **Consistency**: Same display everywhere in the app
- **Testability**: Pure formatting logic easy to test

#### Removal Instructions
```swift
// ModelDisplayWire.swift
/*
 To remove ModelDisplay completely:
 1. Delete ATOM-23-ModelDisplay folder
 2. Remove modelDisplayService initialization (line ~151)
 3. Remove modelDisplayService environment object (line ~195)
 4. Remove modelDisplayService.setup() call (line ~231)
 5. Remove from ModelPickerService dependencies
 6. Remove from InputBarView @EnvironmentObject
 7. Replace ModelIndicatorView with hardcoded text
 
 Model names will show as raw IDs
 */
```

### ATOM 24: ModelState
**Purpose**: Manages model selection state, defaults, and overrides  
**Dependencies**: ConfigBus, StateBus, EventBus, ErrorBus, LLMRouter  
**Used by**: PersonaSystem, ModelDisplayService, ModelPickerService  
**One-line**: Central state management for model selection with defaults and user overrides

#### Why It Deserves to Be an Atom
ModelState provides the single source of truth for which AI model is currently active. It handles the complex logic of:
- Default models for different persona types (Anthropic vs non-Anthropic)
- User overrides when manually selecting models
- Persistence across sessions
- Validation against available models
Without this atom, every component would need its own model selection logic, leading to inconsistency and bugs.

#### Structure
```
ATOM-24-ModelState/
├── Models/
│   ├── ModelStateConfiguration.swift    # Configuration and defaults
│   └── ModelStateKeys.swift            # StateBus keys and events
├── Services/
│   └── ModelStateService.swift         # Core state management
├── UI/
│   └── ModelStateDebugView.swift       # Optional debug view
└── Wire/
    └── ModelStateWire.swift            # Integration documentation
```

#### Key Features
- **Dual Defaults**: Separate defaults for Anthropic and non-Anthropic personas
- **Override Management**: User can override defaults via model picker
- **State Persistence**: Selections saved via StateBus
- **Model Validation**: Checks models against LLMRouter availability
- **History Tracking**: Maintains selection history for analytics
- **Dynamic Classification**: Unknown models classified by provider prefix
- **Event Publishing**: Notifies system of model changes

#### State Resolution Logic
```swift
// For Anthropic personas:
if let override = currentAnthropicModel {
    return override  // User selected specific model
} else {
    return defaultAnthropicModel  // Use default
}

// For non-Anthropic personas:
if let override = currentNonAnthropicModel {
    return override  // User selected specific model
} else {
    return defaultNonAnthropicModel  // Use default
}
```

#### Configuration (ModelState.json)
```json
{
  "defaultAnthropicModel": "anthropic:claude-3-5-sonnet",
  "defaultNonAnthropicModel": "openai:gpt-4",
  "anthropicModels": [
    "anthropic:claude-3-5-sonnet",
    "anthropic:claude-3-opus",
    "anthropic:claude-3-haiku"
  ],
  "nonAnthropicModels": [
    "openai:gpt-4",
    "openai:gpt-3.5-turbo",
    "fireworks:llama-v3-70b-instruct"
  ],
  "maxHistorySize": 50,
  "anthropicProviderPrefix": "anthropic:",
  "debugView": {
    "width": 400,
    "height": 600
  }
}
```

#### State Persistence
Uses StateBus with type-safe keys:
```swift
// Model overrides
StateKey.currentAnthropicModel → "anthropic:claude-3-opus"
StateKey.currentNonAnthropicModel → "openai:gpt-4"

// UI state
StateKey.lastSelectedModel → "anthropic:claude-3-5-sonnet"
StateKey.modelSelectionHistory → ["model1", "model2", ...]
```

#### Events Published
```swift
// When user selects a model
ModelSelectedEvent(model: "anthropic:claude-3-5-sonnet")

// When defaults change
ModelDefaultsChangedEvent(
    anthropic: "anthropic:claude-3-5-sonnet",
    nonAnthropic: "openai:gpt-4"
)

// When override is cleared
ModelOverrideClearedEvent(isAnthropic: true)
```

#### Usage Example
```swift
// Select a model (auto-detects type)
modelStateService.selectModel("anthropic:claude-3-opus")

// Get current model for persona type
let model = modelStateService.resolvedAnthropicModel

// Clear user override
modelStateService.clearAnthropicOverride()

// Check available models
let anthropicModels = modelStateService.availableModels(anthropic: true)
```

#### Dynamic Model Handling
When encountering unknown models:
```swift
"anthropic:new-model" → Added to anthropicModels
"openai:new-model" → Added to nonAnthropicModels
"custom:model" → Added to nonAnthropicModels (default)
```

#### Why This Architecture
- **Separation of Concerns**: Model state separate from UI and personas
- **Flexibility**: Easy to add new model types or providers
- **User Control**: Overrides respect user choice
- **Persistence**: Selections survive app restarts
- **Validation**: Ensures only available models are selected

#### Removal Instructions
```swift
// ModelStateWire.swift
/*
 To remove ModelState completely:
 1. Delete ATOM-24-ModelState folder
 2. Remove modelStateService initialization (line ~117)
 3. Remove modelStateService environment object (line ~192)
 4. Remove modelStateService.setup() call (line ~222)
 5. Remove from PersonaSystem dependencies
 6. Remove from ModelDisplayService dependencies
 7. Remove from ModelPickerService dependencies
 8. Replace with hardcoded model selection
 
 Model selection and persistence will be broken
 */
```

### ATOM 25: API Key Storage - Secure Keychain Integration

**One-Line**: Provides secure API key storage using macOS Keychain with setup UI

#### Why API Key Storage Deserves to be an Atom
API keys are the gateway to LLM functionality, and storing them securely is critical. This atom provides a production-grade solution using macOS Keychain, eliminating plaintext storage while offering a smooth setup experience. It handles the complexity of Keychain APIs, batch operations, and auto-migration from .env files.

#### Architecture
```
Keychain/
├── Models/          # Empty (no models needed)
├── Services/
│   └── KeychainService.swift    # Static utility for Keychain operations
├── Views/
│   └── APIKeySetupView.swift    # Setup UI for missing keys
└── Wire/
    └── KeychainWire.swift       # Integration docs
```

#### Key Features
1. **Secure Storage**: Uses macOS Security framework
2. **Batch Operations**: Save/load multiple keys with one password prompt
3. **Auto-Migration**: Moves keys from .env to Keychain automatically
4. **Setup UI**: Clean interface for entering API keys
5. **Error Handling**: Clear messages for common Keychain issues

#### Loading Priority
```
1. DevKeys (if DEBUG)
      ↓
2. Keychain ← This Atom
      ↓
3. Process Environment
      ↓
4. .env file
      ↓
5. Auto-migrate to Keychain
```

#### Keychain Structure
```swift
Service: "com.atomic.aether" // Bundle ID
Accounts:
- ANTHROPIC_API_KEY → sk-ant-api03-...
- OPENAI_API_KEY → sk-proj-...
- FIREWORKS_API_KEY → fw_3Tv9...
```

#### Batch Operations
```swift
// Save all keys at once - single password prompt
KeychainService.saveAPIKeys([
    "ANTHROPIC_API_KEY": anthropicKey,
    "OPENAI_API_KEY": openAIKey,
    "FIREWORKS_API_KEY": fireworksKey
])

// Load all keys at once
let keys = KeychainService.loadAPIKeys([
    "ANTHROPIC_API_KEY",
    "OPENAI_API_KEY", 
    "FIREWORKS_API_KEY"
])
```

#### Security Configuration
```swift
// Keys available after first unlock
kSecAttrAccessible: kSecAttrAccessibleAfterFirstUnlock

// Allows background access while maintaining security
// Keys encrypted until user logs in
```

#### Setup UI Flow
```
App launches → EnvLoader checks for keys
           ↓
Keys missing? → Show APIKeySetupView sheet
           ↓
User enters keys → Test connections
           ↓
Save to Keychain → Dismiss sheet
           ↓
App continues with secured keys
```

#### Password Prompt Handling
- macOS prompts for Keychain access
- Frequency depends on code signing
- Users can add app to "Always Allow"
- DevKeys atom eliminates prompts during development

#### Integration Points
- **EnvLoader**: Primary consumer, checks Keychain first
- **APIKeySetupView**: Presented when keys missing
- **atomic_aetherApp**: Manages setup sheet presentation
- **LLM Services**: Use loaded keys for API calls

#### Error Cases
```swift
enum KeychainError: Error {
    case itemNotFound         // Key doesn't exist
    case duplicateItem        // Key already exists
    case invalidData          // Corrupted data
    case authenticationFailed // User denied access
    case unhandledError(OSStatus) // Other errors
}
```

#### Why This Architecture
- **Static Utility**: No state needed, pure functions
- **Batch Operations**: Minimize password prompts
- **Auto-Migration**: Smooth transition from .env files
- **Type Safety**: Strongly typed key names
- **Error Recovery**: Graceful fallbacks

#### Removal Instructions
```swift
// KeychainWire.swift
/*
 To remove API Key Storage:
 1. Delete ATOM-25-Keychain folder
 2. Update EnvLoader to skip Keychain
 3. Remove APIKeySetupView sheet
 4. API keys in .env files only
 
 WARNING: Plaintext storage only!
 */
```

### ATOM 26: Environment Loader - Multi-Source API Key Loading

**One-Line**: Loads API keys from DevKeys, Keychain, environment variables, or .env files with auto-migration

#### Why Environment Loader Deserves to be an Atom
Environment Loader solves the complex problem of API key management across different environments (development, testing, production) with a smart fallback chain. It seamlessly integrates with DevKeys for development, Keychain for security, and .env files for simplicity, while auto-migrating keys to secure storage. Without this atom, each service would implement its own key loading logic, leading to inconsistency and security vulnerabilities.

#### Architecture
```
EnvLoader/
├── Models/
│   ├── Environment.swift               # Core environment model
│   └── EnvLoaderConfiguration.swift    # Configuration structure
├── Services/
│   └── EnvLoader.swift                 # Multi-source loader
├── Events/
│   └── EnvLoaderEvents.swift          # Loading events
└── Wire/
    └── EnvLoaderWire.swift            # Integration docs
```

#### Loading Priority Chain
```
1. DevKeys (if DEBUG)
      ↓ not found
2. Keychain
      ↓ not found
3. Process Environment
      ↓ not found
4. .env file
      ↓ found!
5. Auto-migrate to Keychain
      ↓
   Return key
```

#### Configuration (EnvLoader.json)
```json
{
  "apiKeyNames": {
    "anthropic": "ANTHROPIC_API_KEY",
    "openai": "OPENAI_API_KEY",
    "fireworks": "FIREWORKS_API_KEY"
  },
  "envFilePaths": [
    ".env",
    "../.env", 
    "~/.env"
  ],
  "autoMigrateToKeychain": true,
  "logLevel": "info"
}
```

#### .env File Format
```bash
# .env file in project root
ANTHROPIC_API_KEY=sk-ant-api03-...
OPENAI_API_KEY=sk-proj-...
FIREWORKS_API_KEY=fw_3Tv9...

# Comments and blank lines ignored
# Quotes optional: KEY="value" or KEY=value
```

#### API Key Access
```swift
// Load all keys on startup
envLoader.loadAPIKeys()

// Get specific key
if let anthropicKey = envLoader.apiKey(for: .anthropic) {
    // Configure Anthropic service
}

// Check availability
if envLoader.hasAPIKey(for: .openai) {
    // Enable OpenAI features
}

// Get all loaded providers
let providers = envLoader.loadedKeys // [.anthropic, .openai]
```

#### Auto-Migration Flow
```
Found key in .env?
      ↓
Already in Keychain?
      ↓ No
Save to Keychain
      ↓
Delete from memory
      ↓
Future loads use Keychain
```

#### Integration Points
- **atomic_aetherApp**: Initializes and calls loadAPIKeys()
- **LLM Services**: Retrieve keys via apiKey(for:)
- **DevKeys**: First check if enabled (ATOM 27)
- **KeychainService**: Second check for secure storage (ATOM 25)
- **ConfigBus**: Loads configuration

#### Error Handling
```swift
// Missing .env - Silent, not an error
// Malformed .env - Log warning, continue
// Keychain locked - Fall back to .env
// No keys found - Return nil, let services handle
```

#### Security Best Practices
1. **Never commit .env files** - Add to .gitignore
2. **Use DevKeys in development** - No password prompts
3. **Auto-migrate to Keychain** - Secure production keys
4. **Validate keys** - Check format before use
5. **Clear from memory** - After migration

#### Why This Architecture
- **Flexibility**: Works in any environment
- **Security**: Auto-upgrades to secure storage
- **Developer Experience**: Multiple fallback options
- **Zero Configuration**: Works with defaults
- **Observable**: Events for monitoring

#### Removal Instructions
```swift
// EnvLoaderWire.swift
/*
 To remove Environment Loader:
 1. Delete ATOM-26-EnvLoader folder
 2. Remove loadAPIKeys() call
 3. Hardcode keys in services
 4. Delete .env file
 
 WARNING: No automatic key loading!
 */
```

### ATOM 27: DevKeys - Password-Free Development

**One-Line**: Eliminates Keychain password prompts during development by storing API keys in UserDefaults

#### Why DevKeys Deserves to be an Atom
DevKeys solves a specific developer pain point: constant macOS Keychain password prompts during development. Every app restart, every test run, every debugging session triggers multiple password dialogs. This atom provides a secure-enough alternative for development while maintaining production security. Without it, developers face constant interruptions or resort to dangerous practices like hardcoding keys.

#### Architecture
```
DevKeys/
├── Core/
│   └── DevKeys.swift                   # Atom coordinator
├── Models/
│   └── DevKeysConfiguration.swift      # Configuration model
├── Services/
│   └── DevKeysService.swift           # UserDefaults storage
├── UI/
│   └── DevKeysToggleView.swift        # Toggle UI component
├── Events/
│   └── DevKeysEvents.swift            # State change events
└── Wire/
    └── DevKeysWire.swift              # Integration docs
```

#### The Problem It Solves
```
Without DevKeys:
Start app → Password prompt
Test API → Password prompt  
Debug code → Password prompt
Switch models → Password prompt
😤 Frustrated developer

With DevKeys:
Start app → No prompt ✓
Test API → No prompt ✓
Debug code → No prompt ✓  
Switch models → No prompt ✓
😊 Happy developer
```

#### Configuration (DevKeys.json)
```json
{
  "autoEnableInDebug": true,
  "clearOnDisable": true,
  "showMigrationButton": true,
  "storage": {
    "suiteName": null,
    "keyPrefix": "DevKeys_"
  },
  "ui": {
    "warningText": "⚠️ DevKeys Active - Insecure Storage",
    "warningColor": "#FF6B6B",
    "toggleLabel": "Use DevKeys (Development Only)",
    "showInRelease": false
  }
}
```

#### How It Works
```swift
// In DEBUG builds, automatically enabled
#if DEBUG
if configuration.autoEnableInDebug {
    isEnabled = true
}
#endif

// Storage in UserDefaults (no password needed)
UserDefaults.standard.set(apiKey, forKey: "DevKeys_ANTHROPIC_API_KEY")

// EnvLoader checks DevKeys first
if devKeysService.isEnabled {
    if let key = devKeysService.getKey(keyName) {
        return key  // No Keychain access needed!
    }
}
```

#### Integration with EnvLoader
```
EnvLoader Priority:
1. DevKeys (if enabled) ← This Atom
2. Keychain
3. Environment
4. .env file
```

#### Visual Warning
```swift
if devKeysService.isEnabled {
    HStack {
        Image(systemName: "exclamationmark.triangle.fill")
        Text("⚠️ DevKeys Active - Insecure Storage")
    }
    .foregroundColor(Color(hex: "#FF6B6B"))
    .padding()
    .background(Color(hex: "#FF6B6B").opacity(0.1))
    .cornerRadius(8)
}
```

#### Migration Feature
```swift
Button("Migrate from Keychain") {
    // Load all keys from Keychain
    let keys = KeychainService.loadAPIKeys(keyNames)
    
    // Save to DevKeys
    for (name, value) in keys {
        devKeysService.saveKey(name, value: value)
    }
    
    // Single password prompt for all keys!
}
```

#### Security Boundaries
```swift
// Production safety
#if !DEBUG
if configuration.ui.showInRelease == false {
    // Toggle hidden in release builds
    return EmptyView()
}
#endif

// Clear on disable
if !isEnabled && configuration.clearOnDisable {
    clearAllKeys()  // Remove from UserDefaults
}
```

#### Integration Points
- **EnvLoader**: Checks DevKeys before Keychain
- **APIKeySetupView**: Shows toggle and migration UI
- **atomic_aetherApp**: Initializes service
- **Configuration**: Hot-reload settings

#### Developer Experience
1. **Zero Friction**: No password prompts during development
2. **Quick Toggle**: Enable/disable with one click
3. **Batch Migration**: Move all keys from Keychain at once
4. **Visual Feedback**: Clear warning when active
5. **Auto-Enable**: Starts enabled in DEBUG builds

#### Why This Architecture
- **Minimal Surface**: Only touches EnvLoader's loading chain
- **Clear Boundaries**: DEBUG-only by default
- **User Control**: Explicit toggle and migration
- **Safety First**: Visual warnings and auto-clear
- **Zero Config**: Works out of the box

#### Removal Instructions
```swift
// DevKeysWire.swift
/*
 To remove DevKeys:
 1. Delete ATOM-27-DevKeys folder
 2. Remove from EnvLoader checks
 3. Remove toggle from APIKeySetupView
 4. Delete DevKeys.json
 
 Back to password prompts!
 */
```

### ATOM 28: Models - LLM Model Definitions and Registry

**One-Line**: Provides core data structures and registry service for LLM model definitions and validation

#### Why Models Deserves to be an Atom
Models atom is the "data dictionary" for LLM interactions. It centralizes model definitions, validation logic, and role types that are used across multiple atoms. Without it, model strings would be scattered throughout the codebase with no validation, leading to runtime errors from typos and inconsistent role handling. It's the foundation that makes model management reliable and configuration-driven.

#### Architecture
```
Models/
├── Core/
├── Models/
│   └── MessageRole.swift              # Role enumeration
├── Services/
│   └── ModelRegistryService.swift     # Model validation
├── Events/
│   └── ModelEvents.swift              # Model lifecycle events
├── UI/
│   └── ModelDebugView.swift           # Debug interface
└── Wire/
    └── ModelsWire.swift               # Integration docs
```

#### Core Data Structures
```swift
// Type-safe message roles
enum MessageRole: String, Codable {
    case system = "system"
    case user = "user"
    case assistant = "assistant"
}

// Used throughout the system
let message = LLMMessage(
    role: MessageRole.user,  // Type-safe, no strings
    content: "Hello"
)
```

#### Model Registry Service
```swift
@MainActor
class ModelRegistryService: ObservableObject {
    // Validate model strings
    func isValidModel(_ modelString: String) -> Bool {
        // Checks against LLMProviders.json
        // "anthropic/claude-3-opus" → true
        // "anthropic/invalid-model" → false
    }
    
    // Get available models
    func availableModels(for provider: LLMProvider) -> [String] {
        // Returns ["claude-3-opus", "claude-3-sonnet", ...]
    }
}
```

#### Configuration Integration
Models are defined in `LLMProviders.json`:
```json
{
  "providers": {
    "anthropic": {
      "models": {
        "claude-3-opus": {
          "displayName": "Claude 3 Opus",
          "maxTokens": 200000
        },
        "claude-3-sonnet": {
          "displayName": "Claude 3 Sonnet",
          "maxTokens": 200000
        }
      }
    }
  }
}
```

#### Events Published
```swift
// When models are loaded from config
ModelsLoadedEvent(providers: [.anthropic, .openai, .fireworks])

// When validation fails
ModelValidationFailedEvent(modelString: "invalid/model")
```

#### Who Depends on Models
1. **LLM Services**: Use MessageRole for API formatting
2. **Model Picker**: Uses registry to show available models
3. **Model State**: Validates selections against registry
4. **Conversation Flow**: Constructs messages with roles
5. **System Prompt Builder**: Uses system role for prompts

#### Validation Flow
```swift
// User selects a model
let selectedModel = "anthropic/claude-3-opus"

// ModelState validates via registry
if modelRegistry.isValidModel(selectedModel) {
    // Safe to use
    modelStateService.setCurrentModel(selectedModel)
} else {
    // Show error
    errorBus.report(ModelError.invalidModel)
}
```

#### Debug Interface
```swift
ModelDebugView(modelRegistry: modelRegistry)
// Shows:
// • Anthropic
//   - claude-3-opus
//   - claude-3-sonnet
// • OpenAI
//   - gpt-4
//   - gpt-3.5-turbo
```

#### Why This Architecture
- **Type Safety**: MessageRole enum prevents role typos
- **Centralized Validation**: One place to check model validity
- **Configuration-Driven**: Add models without code changes
- **Event Notifications**: Other atoms react to model changes
- **Clean Separation**: Model definitions separate from services

## 300 Series - Input System

### ATOM 31: Input Bar
**Purpose**: Text input system with views, models, and appearance services  
**Dependencies**: ConversationOrchestrator, ModelPickerService, PersonaStateService, SlashCommandDetector, KeyboardService, ConfigBus, EventBus  
**Used by**: ContentView (main UI)  
**One-line**: Comprehensive text input with expandable TextEditor, integrated pickers, and command support

#### Why It Deserves to Be an Atom
Input Bar is the primary user interaction point that orchestrates multiple complex features:
- Multiline text input with dynamic expansion
- Real-time persona switching by typing names
- Integrated model and persona picker menus
- Slash command detection and processing
- Smart keyboard handling for different submission patterns
Without this atom, users have no way to communicate with the AI system.

#### Structure
```
ATOM-31-InputBar/
├── Models/
│   └── InputBarAppearance.swift          # Complete UI configuration
├── Services/
│   └── InputBarAppearanceService.swift   # Hot-reload appearance
├── Views/
│   └── InputBarView.swift               # Main input component
└── Wire/
    └── InputBarWire.swift               # Integration documentation
```

#### Key Features
- **Expandable TextEditor**: Grows from 1 to 34 lines
- **Glassmorphic Design**: Semi-transparent with gradient borders
- **Model/Persona Pickers**: Integrated selection menus
- **Slash Commands**: /journal expands to 34 lines
- **Real-time Persona Switch**: Type persona name to switch
- **Smart Return Keys**: Configurable submit behavior
- **Event-based Text Insertion**: Pickers insert via events
- **Focus Management**: Auto-focus with @FocusState
- **Configuration-Driven**: All appearance externalized

#### Input Processing Flow
```
User types → SlashCommandDetector checks
           → PersonaStateService checks first word
           → KeyboardService handles return keys
           → Submit → ConversationOrchestrator
```

#### Configuration (InputBarAppearance.json)
```json
{
  "dimensions": {
    "width": 700,
    "defaultHeight": 60,
    "bottomMargin": 20,
    "cornerRadius": 18,
    "textFieldMinHeight": 28
  },
  "multiline": {
    "enabled": true,
    "maxLines": 34,
    "lineHeight": 22
  },
  "glassmorphic": {
    "backgroundOpacity": 0.85,
    "borderTopOpacity": 0.25,
    "borderBottomOpacity": 0.1,
    "blurRadius": 20
  },
  "controls": {
    "spacing": 12,
    "plusButton": {
      "iconName": "plus",
      "size": 16,
      "opacity": 0.5
    },
    "modelPicker": {
      "fontSize": 12,
      "opacity": 0.7
    },
    "greenIndicator": {
      "size": 6,
      "color": "green",
      "glowRadius1": 2,
      "glowRadius2": 5,
      "glowOpacity": 0.5
    }
  },
  "textField": {
    "textColor": "white",
    "fontSize": 14,
    "fontFamily": "system"
  }
}
```

#### Slash Command Integration
```swift
// Detects commands in real-time
slashCommandDetector.handleTextChange(text)

// /journal command:
- Expands input to 34 lines
- Clears text after detection
- Escape key collapses
- Maintains expanded state during typing
```

#### Persona Switching
```swift
// First word detection
"Claude hello" → Switches to Claude persona
"samara think about" → Switches to Samara persona

// Case-insensitive, real-time
// Works alongside picker selection
```

#### Keyboard Shortcuts
- **Enter**: Submit (default)
- **Shift+Enter**: New line (ChatGPT style)
- **Option+Enter**: New line (Claude style)
- **Cmd+Enter**: Always submit
- **Escape**: Collapse if expanded

#### Event Integration
```swift
// Listen for text insertion from pickers
eventBus.subscribe(to: InputEvent.self) { event in
    if case .insertText(let newText, _) = event {
        text = newText
        isTextFieldFocused = true
    }
}
```

#### Submit Logic
```swift
private func handleSubmit() {
    // Validate non-empty
    guard !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
    
    // Prevent double-submit
    guard !conversationOrchestrator.isProcessing else { return }
    
    // Clear immediately for responsiveness
    let message = text
    text = ""
    
    // Process asynchronously
    Task {
        await conversationOrchestrator.processMessage(message)
    }
}
```

#### Why This Architecture
- **Centralized Input**: All user text flows through one component
- **Modular Integration**: Each feature (pickers, commands) is separate
- **Event-Driven**: Loose coupling via EventBus
- **Configuration Control**: UI team can tweak without code
- **Responsive Design**: Immediate feedback on all actions

#### Removal Instructions
```swift
// InputBarWire.swift
/*
 To remove Input Bar completely:
 1. Delete ATOM-31-InputBar folder
 2. Remove InputBarView() from ContentView (line ~27)
 3. Remove modelPickerService dependencies
 4. Remove personaStateService dependencies
 5. Remove conversationOrchestrator dependencies
 
 Users cannot send messages without alternative input
 */
```

### ATOM 32: /journal Slash Command
**Purpose**: Expands input to 34 lines when /journal typed  
**Dependencies**: SlashCommandDetector (ATOM 33)  
**Used by**: InputBar  
**One-line**: Pure configuration that transforms input into a full-page journal editor

#### Why It Deserves to Be an Atom
The /journal command is the perfect example of a configuration-only atom. It requires:
- Zero code changes
- Zero new files
- Just one JSON entry
Yet it provides a complete user feature: the ability to write long-form journal entries. This demonstrates the power of configuration-driven development (Boss Rule #3).

#### Implementation
Located in `SlashCommandDetector.json`:
```json
{
  "trigger": "/journal",
  "expandToLines": 34,
  "description": "Expand input for journal entry"
}
```

#### How It Works
1. User types "/journal" in input bar
2. SlashCommandDetector detects the trigger
3. Input expands to 34 lines (748px height)
4. Text is cleared automatically
5. User writes long-form content
6. Escape key collapses back to normal

#### Configuration Details
- **trigger**: "/journal" - The command to detect
- **expandToLines**: 34 - Number of visible lines
- **description**: User-facing description
- **Case-insensitive**: Controlled by detector config
- **Auto-clear**: Text cleared after detection

#### Related Commands
The configuration includes other commands:
- **/note**: 10 lines for quick notes
- **/code**: 20 lines for code snippets
- **/todo**: 5 lines for task lists
- **/clear**: Clears conversation (no expansion)
- **/help**: Shows commands (no expansion)

#### User Experience
```
Type: /journal
Result: Input expands to full height
Action: Write multi-paragraph entries
Exit: Press Escape to collapse
```

#### Why 34 Lines?
- Provides ~750px of vertical space
- Fits most laptop screens without scrolling
- Matches typical journal entry length
- Leaves room for other UI elements

#### Adding New Commands
Simply add to the commands array:
```json
{
  "trigger": "/essay",
  "expandToLines": 40,
  "description": "Write a full essay"
}
```

#### Removal Instructions
```json
// To remove /journal command:
// 1. Delete the /journal entry from commands array
// That's it - no code changes needed
```

This atom perfectly embodies the Atomic LEGO philosophy: maximum user value with minimum complexity.

### ATOM 33: Slash Command Detector
**Purpose**: Detects and processes slash commands  
**Dependencies**: ConfigBus, EventBus  
**Used by**: InputBar  
**One-line**: Configurable command detection engine that enables features like /journal

#### Why It Deserves to Be an Atom
Slash Command Detector is the foundation that makes configuration-only atoms like /journal possible. It provides:
- Reusable command detection logic
- Expansion state management  
- Event-driven command lifecycle
- Complete configuration control
Without this atom, each command would need custom code, violating the DRY principle and Boss Rule #3.

#### Structure
```
ATOM-33-SlashCommandDetector/
├── Models/
│   ├── SlashCommand.swift                    # Command data model
│   └── SlashCommandDetectorConfiguration.swift # Configuration model
├── Services/
│   └── SlashCommandDetector.swift            # Core detection service
├── Events/
│   └── SlashCommandEvents.swift              # Command lifecycle events
└── Wire/
    └── SlashCommandDetectorWire.swift        # Integration documentation
```

#### Key Features
- **Text-based Detection**: Checks each keystroke for commands
- **Case-insensitive Matching**: Configurable sensitivity
- **Expansion Management**: Tracks active command and expanded state
- **Auto-clear Text**: Optional clearing after command detection
- **Collapse Logic**: Escape key handling with validation
- **Event Publishing**: Full lifecycle events
- **Hot-reload Config**: Commands update without restart
- **Legacy Compatibility**: Publishes InputEvent for older code

#### Detection Flow
```
User types → handleTextChange(text)
           → detectCommand(text)
           → Match found?
           → Publish commandDetected
           → Set activeCommand
           → Set isExpanded = true
           → Return clearText flag
           → TextEditor expands
```

#### Configuration (SlashCommandDetector.json)
```json
{
  "commands": [
    {
      "trigger": "/journal",
      "expandToLines": 34,
      "description": "Expand input for journal entry"
    },
    {
      "trigger": "/note",
      "expandToLines": 10,
      "description": "Quick note with medium expansion"
    },
    {
      "trigger": "/code",
      "expandToLines": 20,
      "description": "Code snippet with syntax highlighting"
    },
    {
      "trigger": "/clear",
      "expandToLines": null,
      "description": "Clear the conversation"
    }
  ],
  "detectCaseSensitive": false,
  "clearTextOnExpand": true
}
```

#### Events Published
```swift
enum SlashCommandEvent {
    case commandDetected(command)      // Command recognized
    case commandExpanded(command, lines) // Input expanded
    case commandCollapsed              // Input collapsed
    case commandExecuted(command, text) // Command submitted
}
```

#### State Management
```swift
@Published var activeCommand: SlashCommand?  // Current command
@Published var isExpanded = false           // Expansion state

// Collapse validation
func shouldAllowCollapse(text: String) -> Bool {
    activeCommand != nil && text.isEmpty && isExpanded
}
```

#### Integration with InputBar
```swift
// Detect on each keystroke
let shouldClear = slashCommandDetector.handleTextChange(text)
if shouldClear {
    text = ""
}

// Calculate expansion
let maxLines = slashCommandDetector.activeCommand?.expandToLines 
    ?? appearance.multiline.maxLines

// Handle escape key
.onKeyPress(.escape) {
    if slashCommandDetector.shouldAllowCollapse(text: text) {
        slashCommandDetector.collapse()
        return .handled
    }
    return .ignored
}
```

#### Adding New Commands
```json
{
  "trigger": "/essay",
  "expandToLines": 50,
  "description": "Write a full essay"
}
```
No code changes needed - just add to JSON and reload.

#### Why This Architecture
- **Separation of Concerns**: Detection logic separate from UI
- **Configuration-Driven**: New commands without code
- **Event-Based**: Loose coupling with other atoms
- **State Management**: Clear ownership of expansion state
- **Extensibility**: Easy to add command types

#### Removal Instructions
```swift
// SlashCommandDetectorWire.swift
/*
 To remove Slash Command Detector:
 1. Delete ATOM-33-SlashCommandDetector folder
 2. Remove slashCommandDetector from InputBarView
 3. Remove handleTextChange() calls
 4. Remove expansion logic
 5. Remove escape key handlers
 
 No slash commands will work
 */
```

### ATOM 34: Keyboard Behavior - Smart Return Key Handling

**One-Line**: Provides ChatGPT and Claude-style keyboard shortcuts for newlines vs submit

#### Why Keyboard Behavior Deserves to be an Atom
Different users have different muscle memory - ChatGPT users press Shift+Enter for newlines, Claude users press Option+Enter. This atom makes atomic-aether feel native to both user groups by supporting both patterns simultaneously. It's a perfect example of a small, focused feature that dramatically improves user experience.

#### Architecture
```
KeyboardBehavior/
├── Models/
│   └── KeyboardConfiguration.swift      # Config structure
├── Services/
│   ├── KeyboardService.swift           # Configuration loader
│   └── SmartReturnKeyModifier.swift    # ViewModifier implementation
└── Wire/
    └── KeyboardWire.swift              # Integration docs
```

#### Key Behavior
```
Enter alone      → Submit message
Shift + Enter    → Insert newline (ChatGPT style)
Option + Enter   → Insert newline (Claude style)
```

#### Implementation Pattern
```swift
// ViewModifier approach for clean integration
TextEditor(text: $text)
    .modifier(SmartReturnKeyModifier(
        text: $text,
        keyboardService: keyboardService,
        onSubmit: handleSubmit
    ))
```

#### Configuration (KeyboardBehavior.json)
```json
{
  "enableSmartReturn": true,
  "submitOnReturn": true,
  "newlineModifiers": {
    "shift": true,      // ChatGPT users
    "option": true,     // Claude users
    "command": false,   // Could enable for power users
    "control": false    // Windows/Linux compatibility
  },
  "messages": {
    "submitHint": "Press Enter to send",
    "newlineHint": "Shift+Enter or Option+Enter for new line"
  }
}
```

#### How It Works
```swift
.onKeyPress(.return) { keyPress in
    // Check for modifier keys
    if keyPress.modifiers.contains(.shift) && config.newlineModifiers.shift {
        text.append("\n")
        return .handled
    } 
    
    if keyPress.modifiers.contains(.option) && config.newlineModifiers.option {
        text.append("\n")
        return .handled
    }
    
    // No modifiers = submit
    if config.submitOnReturn {
        onSubmit()
        return .handled
    }
    
    return .ignored
}
```

#### User Experience Benefits
1. **Familiar to Everyone**: Works like ChatGPT AND Claude
2. **No Learning Curve**: Use whichever style you prefer
3. **Configurable**: Disable styles you don't use
4. **Future-Proof**: Easy to add new modifier combinations

#### Integration Points
- **InputBarView**: Applies the modifier to TextEditor
- **KeyboardService**: Loads configuration
- **ConfigBus**: Hot-reload keyboard preferences

#### Edge Cases Handled
```swift
// Empty text - prevent accidental submits
if text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
    return .ignored
}

// Maximum length - prevent newlines at limit
if text.count >= maxLength {
    return .ignored
}
```

#### Why This Architecture
- **ViewModifier**: Clean, reusable, SwiftUI-native
- **Configuration-Driven**: Users can customize behavior
- **Non-Invasive**: Easy to add/remove without breaking TextEditor
- **Event-Based**: Uses SwiftUI's onKeyPress for proper handling

#### Removal Instructions
```swift
// KeyboardWire.swift
/*
 To remove KeyboardBehavior:
 1. Delete ATOM-34-KeyboardBehavior folder
 2. Remove SmartReturnKeyModifier from TextEditor
 3. Add standard .onSubmit { handleSubmit() }
 4. Delete KeyboardBehavior.json
 
 App reverts to Enter = submit only
 */
```

### ATOM 35: JournalCommand - Enhanced /journal Slash Command

**One-Line**: Transforms the /journal command into a rich journal entry experience with timestamps and formatting

#### Why JournalCommand Deserves to be an Atom
While SlashCommandDetector (ATOM 33) handles generic command detection, JournalCommand provides the specific, rich behavior that makes journaling delightful. It auto-inserts formatted headers with dates/times, positions the cursor intelligently, and prepares the input for long-form writing. Without this atom, /journal would just expand the input box with no context or structure.

#### Architecture
```
JournalCommand/
├── Models/
│   └── JournalCommandConfiguration.swift  # Rich configuration
├── Services/
│   └── JournalCommandService.swift       # Command handler
├── Events/
│   └── JournalCommandEvents.swift        # Command lifecycle
└── Wire/
    └── JournalCommandWire.swift          # Integration docs
```

#### Command Enhancement
```
User types: /journal
           ↓
Result:    ## Journal Entry - Thursday, August 10, 2025 - 14:30
           
           [cursor positioned here, ready to type]
           
           [input expanded to 34 lines]
```

#### Configuration (JournalCommand.json)
```json
{
  "expandToLines": 34,
  "clearTextOnExpand": true,
  "autoInsertPrefix": true,
  "prefixTemplate": "## Journal Entry - {date}",
  "dateFormat": "EEEE, MMMM d, yyyy",
  "insertCursorPosition": "newLine",
  "enableTimestamp": true,
  "timestampFormat": "HH:mm"
}
```

#### Prefix Templates
- `{date}` - Replaced with formatted date
- `{time}` - Replaced with formatted time (future)
- `{mood}` - Mood selector (future)
- `{weather}` - Weather info (future)

#### Cursor Positioning Options
```swift
enum InsertPosition {
    case afterPrefix  // "## Entry|"
    case newLine     // "## Entry\n\n|"
    case end         // "## Entry\n\n\n|"
}
```

#### Event Flow
```swift
// Detection
SlashCommandDetector → SlashCommandEvent.detected("/journal")
                    ↓
// Processing
JournalCommandService → Expands input (StateBus)
                     → Inserts prefix (InputEvent)
                     → Publishes JournalCommandExpanded
                    ↓
// User writes and submits
ConversationOrchestrator → JournalCommandCompleted event
```

#### Integration Points
- **SlashCommandDetector**: Detects "/journal" trigger
- **InputBar**: Responds to expansion and text insertion
- **StateBus**: Shares expansion state
- **EventBus**: Coordinates all interactions
- **Future**: Could integrate with Journal atom for auto-save

#### Why Separate from Detector
1. **Single Responsibility**: Detector detects, command executes
2. **Extensibility**: Each command gets its own rich behavior
3. **Configuration**: Command-specific settings
4. **Future Commands**: /todo, /note can have own atoms
5. **Clean Architecture**: No coupling between detection and execution

#### Future Enhancements
```swift
// Planned features
- Entry templates (gratitude, reflection, daily)
- Mood/energy level selectors
- Auto-save to journal with proper formatting
- Voice dictation trigger
- Entry preview/formatting
- Tag suggestions based on content
```

## 400 Series - Personas

### ATOM 41: Personas
**Purpose**: Complete persona system with detection, state management, and indicators  
**Dependencies**: ConfigBus, StateBus, EventBus, ErrorBus, ModelStateService  
**Used by**: ConversationOrchestrator, InputBar, various UI components  
**One-line**: Multi-personality AI system with folder-based definitions and real-time switching

#### Why It Deserves to Be an Atom
PersonaSystem transforms the AI from a single voice into a cast of distinct personalities, each with:
- Unique system prompts and expertise
- Appropriate model defaults (Anthropic vs non-Anthropic)
- Visual indicators and UI integration
- Real-time switching via typing or menu
- Folder-based extensibility
Without this atom, users get a single, static AI personality with no variation.

#### Structure
```
ATOM-41-PersonaSystem/
├── Core/
│   └── PersonaSystem.swift              # Central coordinator
├── Models/
│   ├── PersonaDefinition.swift         # Core persona model
│   ├── PersonaConfiguration.swift      # JSON configuration
│   ├── PersonaFolder.swift            # Folder-based model
│   ├── PersonaStateConfiguration.swift # State defaults
│   ├── PersonaUIConfiguration.swift    # UI strings
│   └── PersonaFolderConfiguration.swift # Folder settings
├── Services/
│   ├── PersonaStateService.swift       # State management
│   ├── PersonaDetector.swift          # Message detection
│   ├── PersonaFolderWatcher.swift     # Folder monitoring
│   └── FrontmatterParser.swift        # YAML parsing
├── Events/
│   ├── PersonaEvents.swift            # State events
│   └── PersonaFolderEvents.swift      # Folder events
├── Extensions/
│   └── PersonaStateKeys.swift         # StateBus keys
├── UI/
│   └── PersonaIndicator.swift         # Visual indicators
└── Wire/
    ├── PersonaSystemWire.swift        # System integration
    └── PersonaFolderWire.swift        # Folder docs

Note: PersonaPickerView is a separate atom (ATOM 42)
```

#### Key Features
- **10+ Pre-configured Personas**: Claude, Samara, Vlad, Eva, etc.
- **Two-tier System**: Functional Experts & Cognitive Voices
- **Folder-based Definitions**: Drop markdown files to add personas
- **YAML Frontmatter**: Metadata in markdown files
- **Real-time Detection**: Type persona name to switch
- **Model Integration**: Each persona has appropriate model type
- **Visual Indicators**: Color-coded UI elements
- **State Persistence**: Remembers last persona
- **Hot-reload**: Folder changes update immediately

#### Persona Definition
```swift
struct PersonaDefinition {
    let id: String              // "claude"
    let displayName: String     // "Claude"
    let role: String?          // "7 Boss Rules Architect"
    let isAnthropic: Bool      // true
    let systemPrompt: String   // Full prompt
    let color: String          // "#FF5733"
    let group: PersonaGroup    // .functionalExperts
}
```

#### Folder Structure
```
aetherVault/Personas/
├── Claude/
│   └── Claude.md    # YAML frontmatter + prompt
├── Samara/
│   └── Samara.md
├── Vlad/
│   └── Vlad.md
└── Eva/
    └── Eva.md
```

#### YAML Frontmatter Example
```yaml
---
displayName: Claude
role: 7 Boss Rules Architect
isAnthropic: true
group: functionalExperts
color: "#FF5733"
---

You are Claude, the architect of the 7 Boss Rules...
[Rest of system prompt]
```

#### Configuration Files
1. **Personas.json** - Built-in persona definitions
2. **PersonaUI.json** - UI labels and typography
3. **PersonaState.json** - Default personas and settings
4. **PersonaFolders.json** - Folder watching configuration

#### Persona Switching Methods
```swift
// 1. Via PersonaPickerView
Menu selection → switchToPersona("claude")

// 2. By typing name
"Claude hello" → Detects "claude" → Switches → "hello"

// 3. Programmatically
personaSystem.switchToPersona("samara")

// 4. Auto-switch on model change
Non-Anthropic model → Default non-Anthropic persona
```

#### Message Detection Flow
```swift
// Input: "Samara think about this problem"
let (persona, content) = personaSystem.processMessage(text)
// Result: persona = "samara", content = "think about this problem"

// Detection is case-insensitive and works with display names
"CLAUDE" → "claude"
"Claude" → "claude"
```

#### Events Published
```swift
// When persona changes
PersonaSwitchedEvent(personaId: "claude", source: "PersonaPicker")

// When persona detected in message
PersonaDetectedEvent(personaId: "samara", message: "Samara help")

// When folder changes
PersonaFolderChangedEvent(personaId: "eva", changeType: .modified)
```

#### State Management
```swift
// Current persona stored in StateBus
StateKey.currentPersona → "claude"

// Defaults by type
StateKey.defaultAnthropicPersona → "claude"
StateKey.defaultNonAnthropicPersona → "samara"
```

#### Integration with Models
```swift
// Each persona specifies model type
claude.isAnthropic = true  → Uses Anthropic models
samara.isAnthropic = false → Uses OpenAI/Fireworks

// Model selection flow
PersonaStateService → isAnthropic flag
                  → ModelStateService
                  → Appropriate default model
```

#### Why This Architecture
- **Extensibility**: Add personas via folders or JSON
- **Hot-reload**: Changes without restart
- **Type Safety**: Enums and structs throughout
- **Event-Driven**: Loose coupling between components
- **User Control**: Multiple switching methods

#### Removal Instructions
```swift
// PersonaSystemWire.swift
/*
 To remove PersonaSystem completely:
 1. Delete ATOM-41-PersonaSystem folder
 2. Remove personaSystem initialization (line ~127)
 3. Remove from all dependencies
 4. Remove PersonaPickerView from InputBar
 5. Use default prompts in ConversationOrchestrator
 
 App will work with single personality
 */
```

### ATOM 42: PersonaPicker
**Purpose**: Interactive persona selection menu  
**Dependencies**: PersonaStateService, ConfigBus, EventBus  
**Used by**: InputBar  
**One-line**: Dropdown menu UI for persona selection matching ModelPicker style

#### Why It Deserves to Be an Atom
PersonaPicker is separated from PersonaSystem to follow the Atomic LEGO principle. It's a pure UI component that:
- Can be placed anywhere in the UI
- Removed without breaking persona functionality 
- Has single responsibility: visual selection
- Matches ModelPicker for consistency
Without this atom, users can still switch personas by typing names, but lose the convenient menu interface.

#### Structure
```
ATOM-42-PersonaPicker/
├── Core/
│   └── PersonaPicker.swift         # Atom coordinator
├── UI/
│   └── PersonaPickerView.swift    # SwiftUI Menu component
└── Wire/
    └── PersonaPickerWire.swift    # Integration documentation
```

#### Key Features
- **Menu Organization**: Functional Experts & Cognitive Voices sections
- **Role Display**: Shows roles in grey (Menlo font, 90% size)
- **Visual Feedback**: Checkmark for current selection
- **Text Insertion**: Inserts persona name on selection
- **Style Matching**: Identical to ModelPickerView
- **Fixed Sizing**: Prevents layout jumps
- **Event Publishing**: Uses InsertTextEvent
- **Configuration-Driven**: All text from PersonaUI.json

#### UI Implementation
```swift
PersonaPickerView(
    fontSize: appearance.controls.modelPicker.fontSize,
    opacity: appearance.controls.modelPicker.opacity,
    focusState: $isTextFieldFocused
)
.fixedSize()  // Critical for consistent spacing
```

#### Menu Structure
```
┌─────────────────────────┐
│ Claude ▾                │  ← Current persona with chevron
└─────────────────────────┘
        ↓ Click
┌─────────────────────────┐
│ FUNCTIONAL EXPERTS      │  ← Section header (uppercase)
│ ✓ Claude — 7 Boss Rules │  ← Checkmark + role in grey
│   Vlad — Business Strat │
│   Gunnar — Engineering  │
│                         │
│ COGNITIVE VOICES        │
│   Samara — Depth & Joy  │
│   Vanessa — Bold Truth  │
└─────────────────────────┘
```

#### Configuration (PersonaUI.json excerpt)
```json
{
  "menuItemLayout": {
    "roleSpacing": " — ",
    "checkmarkIcon": "checkmark"
  },
  "typography": {
    "personaRole": {
      "fontName": "menlo",
      "sizeMultiplier": 0.9,
      "weight": "regular",
      "opacityMultiplier": 0.7
    },
    "sectionHeader": {
      "fontName": "system",
      "sizeMultiplier": 0.9,
      "weight": "medium",
      "opacityMultiplier": 0.6
    }
  }
}
```

#### Selection Flow
```
User clicks menu
    ↓
Dropdown appears
    ↓
User selects "Samara — Depth & Joy"
    ↓
1. personaStateService.switchToPersona("samara")
2. eventBus.publish(InputEvent.insertText("Samara ", source: "PersonaPicker"))
3. Menu closes
4. Input shows: "Samara |" (cursor after space)
```

#### Visual Consistency with ModelPicker
```swift
// Both pickers use identical:
fontSize: appearance.controls.modelPicker.fontSize
opacity: appearance.controls.modelPicker.opacity
.fixedSize() modifier
Same chevron icon
UPPERCASE section headers
Consistent spacing (12pt between pickers)
```

#### Event Integration
```swift
// When persona selected:
eventBus.publish(InputEvent.insertText(
    text: "\(persona.displayName) ",
    source: "PersonaPicker"
))

// InputBar listens and updates:
eventBus.subscribe(to: InputEvent.self) { event in
    if case .insertText(let newText, _) = event {
        text = newText
        isTextFieldFocused = true
    }
}
```

#### Why This Architecture
- **Separation**: UI separate from persona logic
- **Reusability**: Can add picker anywhere
- **Consistency**: Matches ModelPicker exactly
- **Event-Driven**: Loose coupling via events
- **Configuration**: All strings externalized

#### Removal Instructions
```swift
// PersonaPickerWire.swift
/*
 To remove PersonaPicker:
 1. Delete ATOM-42-PersonaPicker folder
 2. Remove PersonaPickerView from InputBar (line ~85)
 3. Remove .fixedSize() modifier
 4. Remove menuItemLayout from PersonaUI.json
 
 Personas work via typing names only
 */
```

## 500 Series - Conversations

### ATOM 51: ConversationFlow - The Heart of Conversation

**One-Line**: Orchestrates the entire conversation flow from user input to LLM response

#### Why ConversationFlow Deserves to be an Atom
ConversationFlow is the central nervous system of conversations, coordinating personas, models, messages, and LLM calls. It brings together all the other atoms into a cohesive conversation experience. Without it, you have components but no actual AI conversations.

#### Architecture
```
ConversationFlow/
├── Core/                    # Empty (services are the core)
├── Models/
│   ├── ConversationRequest.swift    # Request structure
│   ├── ConversationContext.swift    # Session tracking
│   └── ConversationConfiguration.swift
├── Services/
│   ├── ConversationOrchestrator.swift  # Main coordinator
│   └── StreamProcessor.swift           # Real-time streaming
├── Events/
│   └── ConversationFlowEvents.swift    # Lifecycle events
└── Wire/
    └── ConversationFlowWire.swift      # Integration docs
```

#### Core Responsibilities
1. **Message Processing Pipeline**
   ```swift
   await conversationOrchestrator.processMessage(text)
   // 1. Persona detection
   // 2. Context management  
   // 3. Message storage
   // 4. LLM request building
   // 5. Stream handling
   // 6. Event publishing
   ```

2. **Stream Management**
   ```swift
   StreamProcessor handles:
   - Real-time chunk accumulation
   - Message updates during streaming
   - Progress events every 10 chunks
   - Error recovery with clear messages
   - Final message state
   ```

3. **Context Tracking**
   ```swift
   struct ConversationContext {
       let sessionId: UUID
       let currentPersona: String
       let currentModel: String
       var lastActivity: Date
   }
   ```

#### Configuration (ConversationFlow.json)
```json
{
  "userSpeakerName": "Boss",
  "maxContextMessages": 20,
  "streamingEnabled": true,
  "sessionActiveTimeoutSeconds": 3600
}
```

#### Event Flow
```
User types message
    ↓
ConversationStartedEvent (new session)
    ↓
ConversationMessageSentEvent
    ↓
ConversationStreamingEvent (every 10 chunks)
    ↓
ConversationResponseReceivedEvent
    ↓
ConversationCompletedEvent
    |
    └→ ConversationErrorEvent (on failure)
```

#### Error Handling Excellence
```swift
// API key missing
"⚠️ API key missing. Please set up your API keys in Settings (Cmd+Shift+,)"

// Network error
"⚠️ Network error: [description]"

// Rate limit
"⚠️ Rate limit exceeded. Please try again later."

// Model error
"⚠️ Invalid model: [model]"
```

#### Integration Points
- **InputBar**: Calls processMessage() on submit
- **PersonaStateService**: Provides persona and model
- **LLMRouter**: Routes to appropriate provider
- **MessageStore**: Persists all messages
- **ConfigBus**: Loads configuration
- **EventBus**: Publishes lifecycle events
- **ErrorBus**: Reports processing errors

#### How It Works
```swift
// 1. User submits message
processMessage("Tell me about red dwarf stars")

// 2. Persona detection
let (persona, cleanedMessage) = personaStateService.processMessage(text)
// persona: "samara", cleanedMessage: "Tell me about red dwarf stars"

// 3. Create context (or reuse existing)
currentContext = ConversationContext(
    persona: "samara",
    model: "claude-3-5-sonnet-20241022"
)

// 4. Add user message
messageStore.addMessage(Message(
    speaker: "Boss",
    content: cleanedMessage
))

// 5. Build LLM request
let request = ConversationRequest(
    userMessage: cleanedMessage,
    persona: persona,
    systemPrompt: personaPrompt,
    model: model,
    conversationHistory: lastMessages,
    streamingEnabled: true
)

// 6. Stream response
let stream = try await llmRouter.sendMessage(request.toLLMRequest())
await streamProcessor.processStream(stream, messageId: responseId)
```

#### Streaming Magic
```swift
// StreamProcessor accumulates chunks:
"A red"
"A red dwarf"
"A red dwarf is"
"A red dwarf is a"
"A red dwarf is a small"
...

// Each update:
messageStore.updateMessage(id, content: accumulated, isStreaming: true)

// When done:
messageStore.updateMessage(id, content: fullText, isStreaming: false)
eventBus.publish(ConversationCompletedEvent(...))
```

#### Why This Architecture
- **Orchestration**: Central coordinator prevents spaghetti
- **Streaming**: Real-time feedback during generation
- **Context**: Maintains conversation state
- **Events**: Observable lifecycle for extensions
- **Error Recovery**: Graceful failure handling

#### Removal Instructions
```swift
// ConversationFlowWire.swift
/*
 To remove ConversationFlow:
 1. Delete ATOM-51-ConversationFlow folder
 2. Remove orchestrator from atomic_aetherApp.swift
 3. Remove processMessage from InputBar
 4. Replace with simple messageStore.addMessage()
 
 WARNING: No AI responses without this atom!
 */
```

### ATOM 52: Scrollback - The Conversation Canvas

**One-Line**: Displays conversation messages with speaker labels, streaming support, and beautiful formatting

#### Why Scrollback Deserves to be an Atom
Scrollback is the visual heart of atomic-aether, presenting conversations in a clean, readable format. It handles complex UI concerns like message grouping, streaming indicators, speaker labels with persona colors, and empty message filtering. Without it, you have messages in memory but no way to see them.

#### Architecture
```
Scrollback/
├── Core/
│   └── ScrollbackCoordinator.swift     # State management
├── Models/
│   └── ScrollbackAppearance.swift      # UI configuration
├── Views/
│   ├── ScrollbackView.swift            # Main container
│   ├── MessageRow.swift                # Individual messages
│   └── SpeakerLabel.swift              # Speaker indicators
└── Wire/
    └── ScrollbackWire.swift            # Integration docs
```

#### Visual Design
```
█ Boss         Tell me about red dwarf stars

█ Samara       A red dwarf is the smallest and coolest
               type of star on the main sequence...
               
               Red dwarfs make up about 75% of all stars
               in our galaxy. They burn their fuel very
               slowly, which means they can live for
               trillions of years.
```

#### Key Features
1. **Speaker Labels**
   - 2px colored left border (persona color)
   - Fixed 120px width for alignment
   - Speaker name with subtle background
   - Only shown for first message in group

2. **Message Alignment**
   ```
   [120px label] [16px gap] [message content]
   [empty space] [16px gap] [continuation...]
   ```

3. **Message Grouping**
   ```swift
   // Consecutive messages from same speaker:
   showSpeakerLabel = currentSpeaker != previousSpeaker
   bottomPadding = isLastFromSpeaker ? 16 : 4
   ```

4. **Streaming Support**
   ```swift
   if message.isStreaming {
       ProgressView()
           .scaleEffect(0.5)
           .padding(.top, 4)
   }
   ```

#### Configuration (ScrollbackAppearance.json)
```json
{
  "width": 1400,
  "padding": 20,
  "messageSpacing": 4,
  "speakerLabel": {
    "fontSize": 13,
    "borderWidth": 2,
    "nameOpacity": 0.85,
    "backgroundOpacity": 0.05,
    "namePaddingHorizontal": 8,
    "namePaddingVertical": 3,
    "cornerRadius": 4,
    "stackSpacing": 0,
    "labelWidth": 120
  },
  "message": {
    "fontSize": 13,
    "contentOpacity": 0.9,
    "contentLeadingPadding": 16,
    "lastMessageBottomPadding": 16,
    "progressIndicatorScale": 0.5,
    "progressIndicatorPadding": 4,
    "unknownSpeakerColor": "#808080"
  }
}
```

#### Message Flow
```
MessageStore adds message
         ↓
ScrollbackView observes change
         ↓
Determines speaker label visibility
         ↓
Renders MessageRow with label/empty space
         ↓
Applies appropriate bottom padding
```

#### Speaker Label Design
```swift
struct SpeakerLabel {
    // Visual structure:
    // [█] [Speaker Name]
    //  ↑        ↑
    //  |        +-- Subtle background (5% opacity)
    //  +-- 2px colored border (persona color)
}
```

#### Performance Optimizations
1. **Lazy Loading**: Uses ScrollView with LazyVStack
2. **Message Limit**: Only renders visible messages
3. **Efficient Updates**: Only re-renders changed messages
4. **Memory Management**: Old messages can be purged

#### Integration Points
- **MessageStore**: Source of messages to display
- **ConfigBus**: Loads appearance configuration
- **ScrollbackCoordinator**: Manages scroll position and state
- **ContentView**: Contains ScrollbackView as main content

#### Why This Architecture
- **Separation**: Display logic separate from message storage
- **Flexibility**: Easy to swap different UI styles
- **Performance**: Efficient rendering of long conversations
- **Customization**: All visuals configurable via JSON
- **Accessibility**: Supports text selection and VoiceOver

#### Removal Instructions
```swift
// ScrollbackWire.swift
/*
 To remove Scrollback:
 1. Delete ATOM-52-Scrollback folder
 2. Remove from ContentView.swift
 3. Remove coordinator from app init
 4. Delete ScrollbackAppearance.json
 
 WARNING: No message display without this!
 */
```

### ATOM 53: Message Store - Central Message Repository

**One-Line**: Single source of truth for all conversation messages with streaming support

#### Why Message Store Deserves to be an Atom
Message Store is the data backbone of the conversation system. It bridges the gap between ConversationFlow (which generates messages) and Scrollback (which displays them). Without this central repository, each component would manage its own message state, leading to synchronization nightmares and duplicated data. It provides clean separation of concerns: storage logic stays in one place while display and generation logic live elsewhere.

#### Architecture
```
MessageStore/
├── Models/
│   ├── Message.swift                    # Core message model
│   ├── MessageStoreConfiguration.swift  # Configuration model
│   └── MessageStoreEvents.swift         # Event definitions
├── Services/
│   └── MessageStore.swift              # Central storage service
└── Wire/
    └── MessageStoreWire.swift          # Integration docs
```

#### Core Message Model
```swift
struct Message: Identifiable, Equatable {
    let id = UUID()
    let speaker: String       // "Boss", "Claude", "Samara", etc.
    var content: String       // Mutable for streaming updates
    let timestamp = Date()
    var isStreaming: Bool     // Shows progress indicator
    let modelUsed: String?    // "claude-3-5-sonnet", etc.
}
```

#### Key Responsibilities
1. **Message Storage**: Maintains ordered array of all messages
2. **Streaming Updates**: Handles real-time content updates
3. **Memory Management**: Enforces message limits
4. **Change Notifications**: @Published for automatic UI updates
5. **Event Publishing**: Lifecycle events for other atoms

#### Configuration (MessageStore.json)
```json
{
  "maxMessages": 1000,
  "enableEvents": true,
  "trimStrategy": "removeOldest",
  "persistence": {
    "enabled": false,
    "path": null
  },
  "streamingUpdateInterval": 0.1
}
```

#### Message Flow
```
User Message:
ConversationOrchestrator → addMessage() → MessageAddedEvent → ScrollbackView

AI Response:
addMessage(isStreaming: true) → Placeholder appears
     ↓
updateMessage(content: chunk1) → UI updates
     ↓
updateMessage(content: chunk2) → UI updates
     ↓
updateMessage(isStreaming: false) → Complete
```

#### API Surface
```swift
@MainActor
class MessageStore: ObservableObject {
    @Published private(set) var messages: [Message] = []
    
    // Add new message
    func addMessage(_ message: Message)
    
    // Update for streaming
    func updateMessage(
        _ id: UUID, 
        content: String,
        isStreaming: Bool
    )
    
    // Remove message
    func deleteMessage(_ id: UUID)
    
    // Clear all
    func clearAllMessages()
    
    // Find message
    func message(withId id: UUID) -> Message?
}
```

#### Streaming Message Support
```swift
// 1. Add placeholder
let aiMessage = Message(
    speaker: currentPersona,
    content: "",
    isStreaming: true,
    modelUsed: selectedModel
)
messageStore.addMessage(aiMessage)

// 2. Update as chunks arrive
func processStream(_ chunk: String) {
    accumulated += chunk
    messageStore.updateMessage(
        aiMessage.id,
        content: accumulated,
        isStreaming: true
    )
}

// 3. Finalize
messageStore.updateMessage(
    aiMessage.id,
    content: finalContent,
    isStreaming: false
)
```

#### Memory Management
```swift
private func enforceMessageLimit() {
    guard messages.count > configuration.maxMessages else { return }
    
    let removeCount = messages.count - configuration.maxMessages
    messages.removeFirst(removeCount)
    
    if configuration.enableEvents {
        eventBus.publish(MessageLimitReachedEvent(
            removedCount: removeCount
        ))
    }
}
```

#### Events Published
- **MessageAddedEvent**: New message added
- **MessageUpdatedEvent**: Content or streaming state changed
- **MessageDeletedEvent**: Message removed
- **MessagesCleared**: All messages removed
- **MessageLimitReached**: Old messages trimmed

#### Integration Points
- **ConversationOrchestrator**: Writes messages
- **StreamProcessor**: Updates streaming content
- **ScrollbackView**: Observes and displays
- **ConfigBus**: Loads configuration
- **EventBus**: Publishes events

#### Why This Architecture
- **Single Source of Truth**: One place for all message data
- **Reactive Updates**: @Published drives UI automatically
- **Clean Boundaries**: Storage logic isolated from display/generation
- **Streaming-First**: Built for real-time updates
- **Memory Safe**: Prevents unbounded growth

#### Removal Instructions
```swift
// MessageStoreWire.swift
/*
 To remove Message Store:
 1. Delete ATOM-53-MessageStore folder
 2. Remove from ConversationOrchestrator
 3. Remove from ScrollbackView
 4. Remove from StreamProcessor
 
 WARNING: No message storage or display!
 */
```

## 600 Series - App Theme

### ATOM 61: Theme System - Configuration-Driven Visual Consistency

**One-Line**: Provides app-wide theming through design tokens loaded from JSON configuration

#### Why Theme System Deserves to be an Atom
Theme System eliminates hardcoded colors and spacing throughout the codebase, replacing them with a centralized, configuration-driven approach. It enables instant theme changes without recompilation, ensures visual consistency across all components, and makes the app ready for features like dark/light mode switching. Without this atom, every view would define its own colors, making theme changes a nightmare.

#### Architecture
```
ThemeSystem/
├── Models/
│   ├── Theme.swift              # Core theme data model
│   └── DesignTokens.swift       # Configuration structure
├── Services/
│   └── ThemeService.swift       # ConfigBus integration
├── UI/
│   └── ThemedContainer.swift    # View wrapper component
└── Wire/
    └── ThemeSystemWire.swift    # Integration docs
```

#### Core Theme Model
```swift
struct Theme: Equatable {
    let background: Color      // App background (#000000)
    let primaryText: Color     // Main text (#FFFFFF)
    let secondaryText: Color   // Subdued text (#B0B0B0)
    let accent: Color         // Interactive elements (#3B82F6)
}
```

#### Configuration (DesignTokens.json)
```json
{
  "colors": {
    "background": "#000000",
    "primaryText": "#FFFFFF",
    "secondaryText": "#B0B0B0",
    "accent": "#3B82F6",
    "border": "#333333",
    "surface": "#1A1A1A",
    "error": "#EF4444",
    "warning": "#F59E0B",
    "success": "#10B981"
  },
  "spacing": {
    "xs": 4,
    "sm": 8,
    "md": 16,
    "lg": 24,
    "xl": 32
  },
  "typography": {
    "bodySize": 15,
    "headingSize": 20,
    "captionSize": 13,
    "lineHeight": 1.5
  },
  "animation": {
    "quick": 0.15,
    "normal": 0.3,
    "slow": 0.5
  }
}
```

#### Integration Pattern
```swift
// In ContentView.swift
ThemedContainer { theme in
    VStack {
        // All child views automatically receive theme
        Text("Hello")
            .foregroundColor(theme.primaryText)
        
        Button("Action") { }
            .accentColor(theme.accent)
    }
    .background(theme.background)
}
```

#### Hot Reload Flow
```
Edit DesignTokens.json
        ↓
ConfigBus detects change
        ↓
ThemeService reloads
        ↓
Theme @Published updates
        ↓
UI refreshes instantly
```

#### Usage Guidelines
```swift
// ❌ Never hardcode colors
Text("Hello").foregroundColor(.white)
Rectangle().fill(Color(hex: "#3B82F6"))

// ✅ Always use theme
Text("Hello").foregroundColor(theme.primaryText)
Rectangle().fill(theme.accent)

// ✅ Or use environment
@Environment(\.theme) var theme
```

#### Design Token Benefits
1. **Consistency**: Single source of truth for all visual values
2. **Flexibility**: Change entire app appearance via JSON
3. **Scalability**: Easy to add new color roles or themes
4. **Maintenance**: Find and update any color in one place
5. **Collaboration**: Designers can modify without code knowledge

#### Spacing Scale
```swift
// Consistent spacing throughout app
.padding(.horizontal, tokens.spacing.md)  // 16
.spacing(tokens.spacing.sm)               // 8
.offset(y: tokens.spacing.xs)             // 4
```

#### Future Extensions
```swift
// Multiple themes
enum ThemeVariant {
    case dark       // Current default
    case light      // Future addition
    case highContrast // Accessibility
}

// Dynamic sizing
@ScaledMetric var bodySize = tokens.typography.bodySize
```

#### Integration Points
- **ContentView**: Wraps entire app in ThemedContainer
- **ConfigBus**: Loads and watches DesignTokens.json
- **All UI Components**: Access theme via environment
- **Custom Views**: Can define additional theme properties

#### Why This Architecture
- **Separation**: Visual design separate from logic
- **Reactivity**: Automatic UI updates on theme change
- **Simplicity**: One wrapper provides theme everywhere
- **Performance**: Minimal overhead with environment
- **Extensibility**: Easy to add new token categories

#### Removal Instructions
```swift
// ThemeSystemWire.swift
/*
 To remove Theme System:
 1. Delete ATOM-61-ThemeSystem folder
 2. Remove ThemedContainer wrapper
 3. Remove themeService initialization
 4. Delete DesignTokens.json
 
 App reverts to SwiftUI defaults
 */
```

### ATOM 62: [Next Infrastructure Service]
**Purpose**: [To be determined]  
**Dependencies**: [TBD]  
**Used by**: [TBD]  
**Wire**: [TBD]

### ATOM 63: [Next Infrastructure Service]
**Purpose**: [To be determined]  
**Dependencies**: [TBD]  
**Used by**: [TBD]  
**Wire**: [TBD]

## 700 Series - Developer Tools

### ATOM 71: Boss Profile Service - User Context Loader

**One-Line**: Reads all text files from the Boss folder to provide user context for system prompts

#### Why Boss Profile Service Deserves to be an Atom
Boss Profile Service embodies the philosophy that "the folder IS the profile." It provides a zero-friction way for users to maintain their context - just drop text files in a folder. No JSON schemas, no structured data, no special formats. This simplicity makes it incredibly powerful: users can update their context with any text editor, and the AI immediately has access to the latest information. Without this atom, users would need to manually update prompts or use complex configuration.

#### Architecture
```
BossProfile/
├── Models/
│   └── BossProfileConfiguration.swift   # Configuration model
├── Services/
│   └── BossProfileService.swift        # File loading service
├── Events/
│   └── BossProfileEvents.swift         # Profile change events
└── Wire/
    └── BossProfileWire.swift           # Integration docs
```

#### The Folder IS The Profile
```
aetherVault/Boss/
├── Boss.md                    # Who you are
├── Boss's expectations.md     # What you expect
├── current-projects.md        # What you're working on
├── preferences.txt            # How you like things
└── [any .md or .txt file]     # Anything else relevant
```

#### Configuration (BossProfile.json)
```json
{
  "folderPath": "~/Documents/code/atomic-aether/aetherVault/Boss",
  "fileExtensions": [".md", ".txt", ".markdown", ".text"],
  "excludePatterns": [".DS_Store", ".gitignore", "*.tmp"],
  "displayName": "Boss",
  "displayColor": "#FFD700",
  "cacheEnabled": true,
  "maxFileSize": 1048576,
  "includeFilenames": true,
  "sortAlphabetically": true
}
```

#### How It Works
```swift
func loadProfile() -> String {
    // 1. Find all text files
    let files = FileManager.default
        .contentsOfDirectory(at: bossFolder)
        .filter { fileExtensions.contains($0.pathExtension) }
        .filter { !excludePatterns.contains($0.lastPathComponent) }
    
    // 2. Sort if configured
    if configuration.sortAlphabetically {
        files.sort { $0.lastPathComponent < $1.lastPathComponent }
    }
    
    // 3. Read and concatenate
    return files.compactMap { file in
        guard let content = try? String(contentsOf: file) else { return nil }
        return """
        === \(file.lastPathComponent) ===
        
        \(content)
        """
    }.joined(separator: "\n\n")
}
```

#### Output Format
```
=== Boss.md ===

# About Me
I'm building atomic-aether to...

=== Boss's expectations.md ===

## Code Quality
- Follow the 7 Boss Rules religiously
- No comments unless critical...

=== current-projects.md ===

## Active Work
1. Implementing ATOM 71-73...
```

#### Integration Points
- **SystemPromptBuilder**: Includes profile in system prompts
- **MessageRow**: Uses displayName and color for "Boss" speaker
- **ConfigBus**: Loads configuration
- **Future**: File watcher for hot-reload

#### Display Customization
```swift
// In MessageRow
if speaker.lowercased() == "boss" {
    name = bossProfileService.bossDisplayName  // "Boss"
    color = bossProfileService.bossColor       // Gold
}
```

#### Usage Philosophy
1. **No Structure Required**: Any text file works
2. **Instant Updates**: Edit files, AI sees changes
3. **Version Control Friendly**: Plain text files
4. **Editor Agnostic**: Use VS Code, vim, TextEdit
5. **Cumulative Context**: All files concatenated

#### File Management
```swift
// Size limits
if fileSize > configuration.maxFileSize {
    // Skip file, log warning
    eventBus.publish(BossProfileEvent.fileTooLarge(filename))
}

// Error handling
do {
    content = try String(contentsOf: url)
} catch {
    // Log error, continue with other files
    errorBus.report(error, from: "BossProfile")
}
```

#### Caching Strategy
```swift
private var cachedProfile: String?
private var cacheTimestamp: Date?

func getProfileForPrompt() -> String {
    if cacheEnabled && cachedProfile != nil {
        return cachedProfile!
    }
    
    let profile = loadProfile()
    cachedProfile = profile
    cacheTimestamp = Date()
    return profile
}
```

#### Why This Architecture
- **Zero Friction**: Drop files and go
- **Human Readable**: Plain text, no encoding
- **Flexible**: Any file organization works
- **Discoverable**: See all context in Finder
- **Maintainable**: Edit with any tool

#### Future Enhancements
```swift
// File watching
let watcher = FileWatcher(path: bossFolder)
watcher.onchange = { [weak self] in
    self?.clearCache()
    self?.eventBus.publish(BossProfileChangedEvent())
}

// Selective loading
func loadProfile(matching: String) -> String {
    // Load only files containing keyword
}
```

#### Removal Instructions
```swift
// BossProfileWire.swift
/*
 To remove Boss Profile Service:
 1. Delete ATOM-71-BossProfile folder
 2. Remove from atomic_aetherApp init
 3. Remove from SystemPromptBuilder
 4. Delete BossProfile.json
 
 No user context in prompts!
 */
```

### ATOM 72: Persona Profile Service - Extensible Persona Knowledge

**One-Line**: Loads persona-specific context files from individual folders to extend each persona's knowledge base

#### Why Persona Profile Service Deserves to be an Atom
Persona Profile Service extends the "folder IS the profile" philosophy to personas, enabling them to evolve beyond their static base prompts. While the base persona definition handles personality and communication style, this atom adds domain knowledge, guidelines, and evolving context. Each persona can grow its expertise by simply adding text files to its folder. Without this atom, personas are frozen in time with only their initial prompts.

#### Architecture
```
PersonaProfile/
├── Models/
│   └── PersonaProfileConfiguration.swift  # Configuration model
├── Services/
│   └── PersonaProfileService.swift       # Lazy-loading service
├── Events/
│   └── PersonaProfileEvents.swift        # Profile change events
└── Wire/
    └── PersonaProfileWire.swift          # Integration docs
```

#### Persona Knowledge Structure
```
aetherVault/Personas/
├── Claude/
│   ├── 7-boss-rules-deep-dive.md        # Detailed coding philosophy
│   ├── swift-best-practices.md          # Swift expertise
│   └── architecture-patterns.txt        # Design patterns
├── Samara/
│   ├── creative-techniques.md           # Creative methods
│   ├── empathy-guidelines.md            # Communication style
│   └── storytelling-framework.txt       # Narrative structures
├── Vlad/
│   ├── startup-playbook.md              # Business strategies
│   └── market-analysis-framework.txt    # Analysis methods
└── [any-persona]/
    └── [knowledge-files.md]              # Extensible
```

#### Configuration (PersonaProfile.json)
```json
{
  "baseFolderPath": "~/Documents/code/atomic-aether/aetherVault/Personas",
  "fileExtensions": [".md", ".txt", ".markdown", ".text"],
  "excludePatterns": [".DS_Store", ".gitignore", "*.tmp"],
  "cacheEnabled": true,
  "maxFileSize": 524288,
  "includeFilenames": true,
  "sortAlphabetically": true,
  "lazyLoading": true,
  "fallbackToEmpty": true
}
```

#### Lazy Loading Strategy
```swift
private var profileCache: [String: String] = [:]

func getProfileForPrompt(personaId: String) -> String {
    // Check cache first
    if cacheEnabled, let cached = profileCache[personaId] {
        return cached
    }
    
    // Load only when needed
    let personaFolder = baseFolderPath
        .appendingPathComponent(personaId.capitalized)
    
    guard FileManager.default.fileExists(atPath: personaFolder.path) else {
        return ""  // No profile folder = no extended context
    }
    
    let profile = loadProfile(from: personaFolder)
    profileCache[personaId] = profile
    return profile
}
```

#### Profile Loading
```swift
func loadProfile(from folder: URL) -> String {
    let files = try? FileManager.default
        .contentsOfDirectory(at: folder, includingPropertiesForKeys: nil)
        .filter { url in
            fileExtensions.contains(url.pathExtension) &&
            !excludePatterns.contains(url.lastPathComponent)
        }
        .sorted { $0.lastPathComponent < $1.lastPathComponent }
    
    return files?.compactMap { file in
        guard let content = try? String(contentsOf: file),
              file.fileSize <= maxFileSize else { return nil }
              
        return """
        === \(file.lastPathComponent) ===
        
        \(content)
        """
    }.joined(separator: "\n\n") ?? ""
}
```

#### Integration with System Prompts
```swift
// In SystemPromptBuilder
let basePrompt = persona.systemPrompt  // Personality
let profile = personaProfileService
    .getProfileForPrompt(personaId: currentPersona)  // Knowledge

let fullPrompt = """
\(basePrompt)

\(profile.isEmpty ? "" : "ADDITIONAL CONTEXT:\n\n\(profile)")
"""
```

#### Separation of Concerns
```
Base Prompt (Personas.json):
- Personality traits
- Communication style  
- Core behaviors
- Identity

Profile (Folder files):
- Domain knowledge
- Specific guidelines
- Evolving context
- Reference materials
```

#### Usage Examples

**Claude's Extended Knowledge**:
```markdown
=== 7-boss-rules-deep-dive.md ===

# Deep Dive: The 7 Boss Rules

## Rule 1: Swifty - Detailed Examples
When we say "Swifty," we mean...

## Rule 2: Atomic LEGO - Architecture Patterns
The key to atomic design is...
```

**Samara's Creative Framework**:
```markdown
=== storytelling-framework.md ===

# Narrative Structures I Use

## Three-Act Structure
1. Setup: Establish the world...
2. Confrontation: Challenge appears...
3. Resolution: Transformation occurs...
```

#### Cache Management
```swift
// Clear specific persona
func clearCache(for personaId: String) {
    profileCache.removeValue(forKey: personaId)
    eventBus.publish(PersonaProfileClearedEvent(personaId))
}

// Clear all
func clearAllCaches() {
    profileCache.removeAll()
    eventBus.publish(AllPersonaProfilesClearedEvent())
}

// Preload specific personas
func preloadProfiles(for personaIds: [String]) {
    personaIds.forEach { _ = getProfileForPrompt(personaId: $0) }
}
```

#### Why This Architecture
- **Lazy Loading**: Only loads what's needed
- **Extensible**: Add knowledge without code changes
- **Organized**: Each persona has its own space
- **Versioned**: Text files work with Git
- **Discoverable**: Browse knowledge in Finder

#### Best Practices
1. **Base vs Profile**: Personality in base, knowledge in profile
2. **File Naming**: Clear, descriptive names
3. **File Size**: Keep individual files focused
4. **Organization**: Group related concepts
5. **Evolution**: Update profiles as personas learn

#### Future Enhancements
```swift
// Selective loading
func getProfile(personaId: String, topic: String) -> String {
    // Load only files matching topic
}

// Profile metrics
func profileStats(personaId: String) -> ProfileStats {
    // File count, total size, last modified
}

// Hot reload
FileWatcher(path: personaFolder).onChange = {
    clearCache(for: personaId)
}
```

#### Removal Instructions
```swift
// PersonaProfileWire.swift
/*
 To remove Persona Profile Service:
 1. Delete ATOM-72-PersonaProfile folder
 2. Remove from atomic_aetherApp init
 3. Remove from SystemPromptBuilder
 4. Delete PersonaProfile.json
 
 Personas limited to base prompts only!
 */
```