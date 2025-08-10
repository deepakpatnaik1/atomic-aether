//
//  PersonaSystemWire.swift
//  atomic-aether
//
//  Integration documentation for PersonaSystem
//
//  ATOM 401: PersonaSystem - Removal and integration instructions
//

/*
 REMOVAL INSTRUCTIONS:
 To remove PersonaSystem completely:
 1. Delete ATOM-401-PersonaSystem folder
 2. Remove personaSystem initialization from atomic_aetherApp.swift (line ~127)
 3. Remove personaStateService extraction from atomic_aetherApp.swift (line ~137)
 4. Remove personaSystem environment object from atomic_aetherApp.swift (line ~189)
 5. Remove personaStateService environment object from atomic_aetherApp.swift (line ~193)
 6. Remove personaSystem.setup() call from atomic_aetherApp.swift (line ~209)
 7. Remove personaStateService.setup() call from atomic_aetherApp.swift (line ~225)
 8. Remove personaStateService from ConversationOrchestrator dependencies (line ~145)
 9. Remove persona detection from ConversationOrchestrator.processMessage()
 10. Remove currentPersona from system prompt generation
 11. Remove PersonaPickerView from InputBarView (line ~85)
 12. Remove persona switching logic from InputBarView (lines ~157, ~189)
 
 WARNING: Without PersonaSystem, the app will use default prompts only.
 No persona switching, no personality variations, no folder-based personas.
 
 INTEGRATION POINTS:
 - atomic_aetherApp.swift: Creates PersonaSystem and extracts PersonaStateService
 - ConversationOrchestrator: Uses for system prompt and model selection
 - InputBarView: Detects persona names for real-time switching
 - PersonaPickerView: UI component for manual selection (ATOM 402)
 - ModelStateService: Determines defaults based on persona type
 - aetherVault/Personas/: Folder-based persona definitions
 - ConfigBus: Loads Personas.json, PersonaUI.json, PersonaState.json
 - StateBus: Persists current persona selection
 - EventBus: Publishes persona events
 
 ARCHITECTURE:
 PersonaSystem coordinates multiple services:
 - PersonaStateService: Core state management
 - PersonaDetector: Message-based detection
 - PersonaFolderWatcher: Dynamic folder monitoring
 
 CONFIGURATION FILES:
 1. Personas.json - Persona definitions
 2. PersonaUI.json - UI labels and styling
 3. PersonaState.json - State service defaults
 4. PersonaFolders.json - Folder watching config
 
 PERSONA DEFINITION:
 ```swift
 struct PersonaDefinition {
     let id: String           // "claude"
     let displayName: String  // "Claude"
     let role: String?        // "7 Boss Rules Architect"
     let isAnthropic: Bool   // true
     let systemPrompt: String // Full prompt text
     let group: PersonaGroup  // .functionalExperts
 }
 ```
 
 FOLDER-BASED PERSONAS:
 aetherVault/Personas/
 ├── Claude/
 │   └── Claude.md       # YAML frontmatter + markdown
 ├── Samara/
 │   └── Samara.md
 └── Vlad/
     └── Vlad.md
 
 YAML FRONTMATTER:
 ```yaml
 ---
 displayName: Claude
 role: 7 Boss Rules Architect
 isAnthropic: true
 group: functionalExperts
 color: #FF5733
 ---
 # System prompt content here
 ```
 
 STATE MANAGEMENT:
 - Current persona ID stored in StateBus
 - Defaults to "claude" for Anthropic
 - Defaults to "samara" for non-Anthropic
 - Persists across app restarts
 
 PERSONA SWITCHING:
 1. Via PersonaPickerView menu
 2. By typing persona name (e.g., "Claude hello")
 3. Programmatically via switchToPersona()
 4. Auto-switch based on model type
 
 MESSAGE DETECTION:
 ```swift
 let (persona, content) = personaSystem.processMessage(text)
 // "Claude hello" → persona: "claude", content: "hello"
 ```
 
 EVENTS PUBLISHED:
 - PersonaSwitchedEvent(personaId, source)
 - PersonaDetectedEvent(personaId, message)
 - PersonaFolderChangedEvent(personaId, changeType)
 - PersonaFolderErrorEvent(error)
 
 SYSTEM PROMPT GENERATION:
 ```swift
 let prompt = personaStateService.systemPromptForCurrentPersona()
 // Returns full prompt from persona definition or folder
 ```
 
 MODEL SELECTION:
 ```swift
 let model = personaStateService.modelForCurrentPersona()
 // Returns appropriate model based on isAnthropic flag
 ```
 
 BEST PRACTICES:
 - Keep persona prompts focused
 - Use clear, distinct names
 - Set appropriate isAnthropic flags
 - Organize into logical groups
 - Test persona switching thoroughly
 - Monitor folder changes in development
 */