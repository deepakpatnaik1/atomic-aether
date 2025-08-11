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