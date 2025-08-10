//
//  ModelStateWire.swift
//  atomic-aether
//
//  Integration documentation for ModelState
//
//  ATOM 204: ModelState - Removal and integration instructions
//

/*
 REMOVAL INSTRUCTIONS:
 To remove ModelState completely:
 1. Delete ATOM-204-ModelState folder
 2. Remove modelStateService initialization from atomic_aetherApp.swift (line ~117)
 3. Remove modelStateService environment object from atomic_aetherApp.swift (line ~192)
 4. Remove modelStateService.setup() call from atomic_aetherApp.swift (line ~222)
 5. Remove modelStateService from PersonaSystem dependencies (line ~132)
 6. Remove modelStateService from ModelDisplayService dependencies (line ~154)
 7. Remove modelStateService from ModelPickerService dependencies (line ~162)
 8. Replace model resolution logic with hardcoded defaults
 
 WARNING: Without ModelState, model selection and persistence will be broken.
 
 INTEGRATION POINTS:
 - atomic_aetherApp.swift: Creates and injects ModelStateService
 - PersonaSystem: Uses ModelState to determine default models
 - ModelDisplayService: Observes ModelState for current model
 - ModelPickerService: Updates ModelState when user selects
 - StateBus: Persists model overrides and history
 - ConfigBus: Loads ModelState.json configuration
 - EventBus: Publishes ModelSelected, ModelDefaultsChanged events
 
 STATE MANAGEMENT:
 ModelStateService maintains:
 - Default models for Anthropic/non-Anthropic personas
 - User overrides via model picker
 - Model selection history
 - Last selected model
 
 RESOLUTION LOGIC:
 For Anthropic personas:
 1. Use currentAnthropicModel override if set
 2. Otherwise use defaultAnthropicModel
 
 For non-Anthropic personas:
 1. Use currentNonAnthropicModel override if set
 2. Otherwise use defaultNonAnthropicModel
 
 CONFIGURATION (ModelState.json):
 ```json
 {
   "defaultAnthropicModel": "anthropic:claude-3-5-sonnet",
   "defaultNonAnthropicModel": "openai:gpt-4",
   "anthropicModels": [
     "anthropic:claude-3-5-sonnet",
     "anthropic:claude-3-opus"
   ],
   "nonAnthropicModels": [
     "openai:gpt-4",
     "openai:gpt-3.5-turbo",
     "fireworks:llama-v3-70b-instruct"
   ],
   "maxHistorySize": 50,
   "anthropicProviderPrefix": "anthropic:"
 }
 ```
 
 STATE PERSISTENCE:
 Uses StateBus with type-safe keys:
 - StateKey.currentAnthropicModel → Override for Anthropic
 - StateKey.currentNonAnthropicModel → Override for non-Anthropic
 - StateKey.lastSelectedModel → Last user selection
 - StateKey.modelSelectionHistory → Selection history array
 
 EVENTS PUBLISHED:
 - ModelSelectedEvent: When user selects a model
 - ModelDefaultsChangedEvent: When defaults are updated
 - ModelOverrideClearedEvent: When override is cleared
 
 DYNAMIC MODEL HANDLING:
 Unknown models are classified by provider prefix:
 - "anthropic:*" → Added to anthropicModels
 - Others → Added to nonAnthropicModels
 
 BEST PRACTICES:
 - Always validate models against LLMRouter
 - Clear overrides when switching persona types
 - Keep history size reasonable (default: 50)
 - Use events for reactive updates
 - Don't hardcode model lists
 */