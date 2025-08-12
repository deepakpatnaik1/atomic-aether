# Atomic-Aether Reference

Quick reference for all atoms and bus usage. For philosophy, see [BOSS-RULES.md](BOSS-RULES.md). For practical guides, see [ATOM-GUIDE.md](ATOM-GUIDE.md).

## Atom Registry

### 100 Series - Foundation Buses
| ATOM | Name | Purpose | Wire Removal Steps |
|------|------|---------|-------------------|
| 101 | EventBus | Pub/sub event routing | Delete folder → atoms can't communicate |
| 102 | ErrorBus | Error handling with toasts | Delete folder → errors log to console only |
| 103 | StateBus | Shared state management | Delete folder → atoms can't share state |
| 104 | ConfigBus | JSON config loading | Delete folder → atoms use default values |

### 200 Series - LLM Models
| ATOM | Name | Purpose | Wire Removal Steps |
|------|------|---------|-------------------|
| 201 | ModelPicker | Model selection UI | Delete folder → no model selection UI |
| 202 | LLMServices | AI provider implementations | Delete folder → no AI responses |
| 203 | ModelDisplay | Model name formatting | Delete folder → raw model IDs shown |
| 204 | ModelState | Model selection state | Delete folder → default models only |
| 205 | Keychain | API key storage | Delete folder → falls back to env vars |
| 206 | EnvLoader | Multi-source key loading | Delete folder → manual key entry |
| 207 | DevKeys | Dev-only key storage | Delete folder → back to password prompts |
| 208 | Models | Model definitions | Delete folder → no model validation |

### 300 Series - Input System
| ATOM | Name | Purpose | Wire Removal Steps |
|------|------|---------|-------------------|
| 301 | InputBar | Text input with pickers | Delete folder → no user input |
| 302 | SlashCommandDetector | Universal command detection | Delete folder → no slash commands |
| 303 | KeyboardBehavior | Smart return keys | Delete folder → Enter = submit only |
| 304 | JournalCommand | /journal command handler | Delete folder → /journal uses basic expansion |

### 400 Series - Personas
| ATOM | Name | Purpose | Wire Removal Steps |
|------|------|---------|-------------------|
| 401 | PersonaSystem | Core persona management | Delete folder → no personas |
| 402 | PersonaPicker | Persona selection UI | Delete folder → no persona UI |
| 403 | BossProfile | User context loader | Delete folder → no user context |
| 404 | PersonaProfile | Per-persona context | Delete folder → base personas only |

### 500 Series - Conversations
| ATOM | Name | Purpose | Wire Removal Steps |
|------|------|---------|-------------------|
| 501 | ConversationFlow | Request orchestration | Delete folder → no conversations |
| 502 | Scrollback | Message display | Delete folder → no message display |
| 503 | MessageStore | Message storage | Delete folder → no message storage |
| 504 | Markdown | Rich text formatting | Delete folder → plain text only |

### 600 Series - App Theme
| ATOM | Name | Purpose | Wire Removal Steps |
|------|------|---------|-------------------|
| 601 | ThemeSystem | Design tokens | Delete folder → default appearance |

### 700 Series - Developer Tools
*Reserved for future development utilities*

### 800 Series - Memory & Persistence
| ATOM | Name | Purpose | Wire Removal Steps |
|------|------|---------|-------------------|
| 801 | Superjournal | Conversation logging | Delete folder → no conversation history saved |

## Quick Bus Reference

### EventBus (ATOM 101)
**Purpose**: Publish/subscribe event routing between atoms

```swift
// Publish
eventBus.publish(YourEvent(data: "value"))

// Subscribe
eventBus.subscribe(to: YourEvent.self) { event in
    // Handle event
}
.store(in: &cancellables)

// Async subscribe
for await event in eventBus.asyncSubscribe(to: YourEvent.self) {
    // Handle async
}
```

### ConfigBus (ATOM 104)
**Purpose**: Load JSON configuration files

```swift
// Load config
let config = configBus.load("ConfigName", as: ConfigType.self)

// With default
let config = configBus.load("ConfigName", as: ConfigType.self) ?? .default

// Check existence
if configBus.hasConfiguration("ConfigName") {
    // Load it
}
```

### StateBus (ATOM 103)
**Purpose**: Share state between atoms

```swift
// Define key
extension StateKey {
    static let myKey = StateKey<String>("myKey")
}

// Set/Get
stateBus.set(.myKey, value: "value")
let value = stateBus.get(.myKey)

// Listen for changes
eventBus.subscribe(to: StateValueChanged.self) { event in
    if event.key == "myKey" {
        // React to change
    }
}
```

### ErrorBus (ATOM 102)
**Purpose**: Centralized error reporting with toast UI

```swift
// Report error
errorBus.report(
    message: "Something went wrong",
    from: "YourService",
    severity: .error,  // .info, .warning, .error, .critical
    error: nsError     // Optional
)

// Apply toast UI to view
YourView()
    .errorToast()
```

## Common State Keys

```swift
// Current values
StateKey.contentWidth          // UI responsive width
StateKey.currentPersona        // Active persona ID
StateKey.currentAnthropicModel // Anthropic model override
StateKey.currentNonAnthropicModel // Non-Anthropic override

// History
StateKey.modelSelectionHistory    // Recent model selections
StateKey.personaConversationHistory // Persona usage

// Flags
StateKey.devModeEnabled        // Developer mode toggle
```

## Common Events

### System Events
- `AppLaunchedEvent`
- `AppTerminatingEvent`
- `ConfigurationChangedEvent(configName)`

### Persona Events
- `PersonaSwitchedEvent(from, to, source)`
- `PersonaDetectedEvent(personaId, message)`
- `PersonaFolderChangedEvent(personaId, changeType)`

### Model Events
- `ModelSelectedEvent(model)`
- `ModelDefaultsChangedEvent(anthropic, nonAnthropic)`
- `ModelsLoadedEvent(providers)`

### Message Events
- `MessageAddedEvent(message)`
- `MessageUpdatedEvent(id, content)`
- `MessagesCleared()`

### Memory Events
- `ConversationEvent.memoryUpdated(type, source)`
- `MemoryUpdateType.superjournalUpdated(path)`

### Input Events
- `InputEvent.insertText(text, source)`
- `SlashCommandEvent.commandDetected(command)`
- `SlashCommandEvent.commandExpanded(command, lines)`

## Configuration Files

All configuration files live in `aetherVault/Config/`:

```
EventBus.json           # Event system settings
ErrorHandling.json      # Error display config
StateBus.json          # State storage limits
ConfigBus.json         # ConfigBus's own config
LLMProviders.json      # AI provider settings
Personas.json          # Persona definitions
InputBarAppearance.json # UI appearance
ModelPicker.json       # Model picker UI
ModelDisplay.json      # Model name formatting
ModelState.json        # Model defaults
DevKeys.json          # Dev key settings
EnvLoader.json        # Key loading config
SlashCommandDetector.json # Command definitions
KeyboardBehavior.json  # Keyboard shortcuts
JournalCommand.json    # Journal command settings
PersonaUI.json        # Persona UI config
PersonaState.json     # Persona defaults
PersonaFolders.json   # Folder watching
BossProfile.json      # Boss folder config
PersonaProfile.json   # Persona folders
ConversationFlow.json # Conversation settings
ScrollbackAppearance.json # Message display
MessageStore.json     # Message limits
MarkdownAppearance.json # Markdown styling
DesignTokens.json     # Theme tokens
```

## Finding Things

### By Feature
- **Want to change UI?** Look in 300s (Input) or 500s (Display)
- **AI not working?** Check 200s (LLM/Models)
- **Events not firing?** Start with 100s (Buses)
- **Personas acting up?** See 400s (Personas)
- **Need conversation history?** Check 800s (Superjournal)

### By Technology
- **SwiftUI Views**: Look for `UI/` folders
- **Business Logic**: Check `Services/` folders
- **Data Models**: Find in `Models/` folders
- **Integration**: Read `Wire/` files

### By File Pattern
```bash
# Find all wire files
find . -name "*Wire.swift"

# Find all configurations
ls aetherVault/Config/*.json

# Find specific atom
ls -la | grep "ATOM-301"
```