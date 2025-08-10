//
//  ModelPickerWire.swift
//  atomic-aether
//
//  Integration documentation for ModelPicker
//
//  ATOM 201: ModelPicker - Removal and integration instructions
//

/*
 REMOVAL INSTRUCTIONS:
 To remove ModelPicker completely:
 1. Delete ATOM-201-ModelPicker folder
 2. Remove modelPickerService initialization from atomic_aetherApp.swift (line ~160)
 3. Remove modelPickerService environment object from atomic_aetherApp.swift (line ~202)
 4. Remove ModelPickerView from InputBarView.swift (line ~76)
 5. Remove modelPickerService from InputBarView @EnvironmentObject (line ~25)
 
 That's it. The app will work but users can't select models via UI.
 
 INTEGRATION POINTS:
 - atomic_aetherApp.swift: Creates and injects ModelPickerService
 - InputBarView.swift: Contains ModelPickerView in toolbar
 - ModelStateService: Picker updates model selection state
 - ModelDisplayService: Updates when picker selects model
 - PersonaStateService: Auto-switches personas based on model type
 - ConfigBus: Loads ModelPicker.json configuration
 - EventBus: Publishes ModelSelectedEvent, InsertTextEvent
 
 UI STRUCTURE:
 ```swift
 ModelPickerView(
     modelPickerService: modelPickerService,
     selectedModel: $selectedModel,
     isExpanded: $isExpanded
 )
 .fixedSize()  // Prevents size jumps
 ```
 
 MODEL GROUPING:
 - Groups models by provider (Anthropic, OpenAI, Fireworks)
 - Shows provider icons and names as section headers
 - Displays model names with checkmarks for selection
 - Configurable provider order and visibility
 
 CONFIGURATION (ModelPicker.json):
 - providerOrder: Display order of providers
 - providerIcons: SF Symbol names for each provider
 - autoSwitchPersona: Whether to switch personas on model change
 - insertPersonaName: Whether to insert persona name in input
 - typography: Font settings for headers and items
 
 AUTO-PERSONA SWITCHING:
 When enabled, selecting a model automatically switches persona:
 - Anthropic model → Default Anthropic persona (claude)
 - Non-Anthropic model → Default non-Anthropic persona (samara)
 
 BEST PRACTICES:
 - Use .fixedSize() to prevent menu size jumps
 - Group models by provider for clarity
 - Show current selection with checkmark
 - Use SF Symbols for provider icons
 - Keep menu items concise
 */