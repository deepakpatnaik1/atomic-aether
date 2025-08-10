//
//  PersonaPickerWire.swift
//  atomic-aether
//
//  Integration documentation for PersonaPicker
//
//  ATOM 402: PersonaPicker - Removal and integration instructions
//

/*
 REMOVAL INSTRUCTIONS:
 To remove PersonaPicker completely:
 1. Delete ATOM-402-PersonaPicker folder
 2. Remove PersonaPickerView from InputBarView.swift (line ~85)
 3. Remove personaStateService check from InputBarView (line ~26)
 4. Remove .fixedSize() modifier from PersonaPicker location (line ~90)
 5. Remove menuItemLayout configuration from PersonaUI.json
 
 That's it. Users can still switch personas by typing the persona name.
 
 INTEGRATION POINTS:
 - InputBarView.swift: Contains PersonaPickerView in controls row
 - PersonaStateService: Provides current persona and switching logic
 - ConfigBus: Loads PersonaUI.json for labels and styling
 - EventBus: Publishes InsertTextEvent when persona selected
 
 UI STRUCTURE:
 ```swift
 PersonaPickerView(
     fontSize: appearance.controls.modelPicker.fontSize,
     opacity: appearance.controls.modelPicker.opacity,
     focusState: $isTextFieldFocused
 )
 .fixedSize()  // Prevents size variations
 ```
 
 MENU ORGANIZATION:
 - Functional Experts section
   - Claude, Vlad, Gunnar, etc.
 - Cognitive Voices section
   - Samara, Vanessa, Lyra, etc.
 - Shows roles in grey next to names
 - Current selection has checkmark
 
 CONFIGURATION (PersonaUI.json):
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
     }
   }
 }
 ```
 
 SELECTION BEHAVIOR:
 1. User clicks menu → Dropdown appears
 2. User selects persona → Menu closes
 3. Persona switches immediately
 4. Persona name inserted in input field
 5. Cursor positioned after inserted text
 
 TEXT INSERTION:
 ```swift
 eventBus.publish(InputEvent.insertText(
     text: "\(persona.displayName) ",
     source: "PersonaPicker"
 ))
 ```
 
 VISUAL CONSISTENCY:
 - Matches ModelPickerView exactly
 - Same font sizes and opacity
 - Consistent chevron icon
 - Unified section headers (UPPERCASE)
 - Role text in Menlo font at 90% size
 
 DEPENDENCIES:
 - PersonaDefinition model from PersonaSystem
 - PersonaStateService for state management
 - PersonaUIConfiguration for all text/styling
 - InputEvent for text insertion
 
 BEST PRACTICES:
 - Always use .fixedSize() modifier
 - Keep menu items concise
 - Show visual feedback (checkmark)
 - Group personas logically
 - Use consistent styling with ModelPicker
 */