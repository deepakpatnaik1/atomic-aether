//
//  ModelDisplayWire.swift
//  atomic-aether
//
//  Integration documentation for ModelDisplay
//
//  ATOM 203: ModelDisplay - Removal and integration instructions
//

/*
 REMOVAL INSTRUCTIONS:
 To remove ModelDisplay completely:
 1. Delete ATOM-203-ModelDisplay folder
 2. Remove modelDisplayService initialization from atomic_aetherApp.swift (line ~151)
 3. Remove modelDisplayService environment object from atomic_aetherApp.swift (line ~195)
 4. Remove modelDisplayService.setup() call from atomic_aetherApp.swift (line ~231)
 5. Remove modelDisplayService from ModelPickerService dependencies (line ~51)
 6. Remove modelDisplayService from InputBarView @EnvironmentObject (line ~24)
 7. Replace ModelIndicatorView with hardcoded text or remove display
 
 That's it. The app will work but won't show formatted model names.
 
 INTEGRATION POINTS:
 - atomic_aetherApp.swift: Creates and injects ModelDisplayService
 - InputBarView.swift: Uses modelDisplayService for current model
 - ModelPickerView.swift: Displays current model in picker label
 - ModelPickerService: Updates display when model changes
 - PersonaStateService: Provides model for current persona
 - ModelStateService: Provides override model selections
 - ConfigBus: Loads ModelDisplay.json configuration
 - EventBus: Listens for PersonaSwitched and ModelSelected events
 
 SERVICE ARCHITECTURE:
 ModelDisplayService observes:
 - PersonaStateService for persona-based model changes
 - StateChangedEvent for persona state updates
 - ModelSelectedEvent for manual model selections
 
 DISPLAY FORMATTING:
 Raw model: "anthropic:claude-3-5-sonnet-20241022"
 Formatted: "Claude 3.5 Sonnet"
 
 Configuration controls:
 - Provider display names
 - Model short names
 - Pattern replacements
 - Show/hide provider prefix
 
 CONFIGURATION (ModelDisplay.json):
 ```json
 {
   "modelDisplayNames": {
     "anthropic:claude-3-5-sonnet": "Claude 3.5 Sonnet"
   },
   "showProvider": false,
   "providerSeparator": " ",
   "providerDisplayNames": {
     "anthropic": "Anthropic",
     "openai": "OpenAI"
   },
   "modelShortNames": {
     "gpt-4": "GPT-4",
     "claude-3-5-sonnet": "Claude 3.5 Sonnet"
   },
   "modelPatternReplacements": {
     "claude-3-5": "Claude 3.5"
   }
 }
 ```
 
 DISPLAY HIERARCHY:
 1. Custom modelDisplayNames (exact match)
 2. modelShortNames (model name only)
 3. Pattern replacements
 4. Generic formatting (capitalize, remove dates)
 
 REUSABLE UI COMPONENT:
 ```swift
 ModelIndicatorView(
     modelDisplayService: modelDisplayService,
     fontSize: 12,
     opacity: 0.7
 )
 ```
 
 BEST PRACTICES:
 - Always format through ModelDisplayService
 - Don't hardcode model display names
 - Use configuration for all mappings
 - Keep display logic in one place
 - Update when adding new models
 */