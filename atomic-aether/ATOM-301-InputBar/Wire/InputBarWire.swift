//
//  InputBarWire.swift
//  atomic-aether
//
//  Integration documentation for Input Bar
//
//  ATOM 301: Input Bar - Removal and integration instructions
//

/*
 REMOVAL INSTRUCTIONS:
 To remove Input Bar completely:
 1. Delete ATOM-301-InputBar folder
 2. Remove InputBarView() from ContentView.swift (line ~27)
 3. Remove all modelPickerService references from InputBarView dependencies
 4. Remove all personaStateService references from InputBarView dependencies
 5. Remove conversationOrchestrator references from InputBarView
 
 WARNING: Without Input Bar, users cannot send messages to the AI.
 You would need an alternative input mechanism.
 
 INTEGRATION POINTS:
 - ContentView.swift: Contains InputBarView as bottom component
 - ConversationOrchestrator: Receives messages for processing
 - ModelPickerService: Provides model selection UI
 - PersonaStateService: Handles real-time persona switching
 - SlashCommandDetector: Expands input for commands
 - KeyboardService: Smart return key handling
 - ConfigBus: Loads InputBarAppearance.json
 - EventBus: Listens for InsertText events
 
 ARCHITECTURE:
 InputBarView is a comprehensive component that includes:
 - TextEditor for multiline input
 - Model picker integration
 - Persona picker integration
 - Slash command detection
 - Smart keyboard handling
 - Glassmorphic styling
 
 TEXT INPUT FLOW:
 1. User types in TextEditor
 2. SlashCommandDetector checks for commands
 3. PersonaStateService checks for persona names
 4. Return key handling via KeyboardService
 5. Submit sends to ConversationOrchestrator
 
 CONFIGURATION (InputBarAppearance.json):
 ```json
 {
   "dimensions": {
     "width": 700,
     "bottomMargin": 20,
     "cornerRadius": 18
   },
   "multiline": {
     "enabled": true,
     "maxLines": 34,
     "lineHeight": 22
   },
   "glassmorphic": {
     "backgroundOpacity": 0.85,
     "borderTopOpacity": 0.25,
     "borderBottomOpacity": 0.1
   },
   "controls": {
     "plusButton": {
       "iconName": "plus",
       "size": 16,
       "opacity": 0.5
     },
     "modelPicker": {
       "fontSize": 12,
       "opacity": 0.7
     }
   }
 }
 ```
 
 SLASH COMMAND INTEGRATION:
 - /journal → Expands to 34 lines
 - Commands detected via SlashCommandDetector
 - Text cleared after command detection
 - Escape key collapses expanded state
 
 PERSONA SWITCHING:
 - First word checked against persona names
 - Immediate UI update on match
 - Case-insensitive detection
 - Works with both pickers and typed names
 
 KEYBOARD HANDLING:
 - Enter → Submit (configurable)
 - Shift+Enter → New line
 - Option+Enter → New line
 - Cmd+Enter → Always submit
 - Escape → Collapse if expanded
 
 MODEL/PERSONA PICKERS:
 - ModelPickerView integrated on left
 - PersonaPickerView integrated next to it
 - Both use .fixedSize() for consistent spacing
 - Insert text via InputEvent
 
 EVENT LISTENING:
 ```swift
 eventBus.subscribe(to: InputEvent.self) { event in
     if case .insertText(let newText, _) = event {
         text = newText
         isTextFieldFocused = true
     }
 }
 ```
 
 BEST PRACTICES:
 - Always clear text after submit
 - Check for empty/whitespace before submit
 - Disable submit during processing
 - Focus text field on appear
 - Use @FocusState for focus management
 - Process messages asynchronously
 */