//
//  PersonaPickerWire.swift
//  atomic-aether
//
//  Integration documentation for PersonaPicker atom
//
//  ATOM 31: PersonaPicker
//

/*
 WIRE POINTS:
 
 1. InputBarView.swift (lines 74-80):
    PersonaPickerView(
        inputText: $text,
        fontSize: appearance.controls.modelPicker.fontSize,
        opacity: appearance.controls.modelPicker.opacity,
        focusState: $isTextFieldFocused
    )
    .fixedSize()
 
 2. PersonaUIConfiguration.swift:
    - Added menuItemLayout property
    - Contains roleSpacing and checkmarkIcon configuration
 
 3. PersonaUI.json:
    - Added menuItemLayout section
    - Contains personaRole typography configuration
 
 DEPENDENCIES:
 - PersonaStateService (from PersonaSystem atom)
 - ConfigBus (for configuration loading)
 - PersonaDefinition model (from PersonaSystem atom)
 
 REMOVAL INSTRUCTIONS:
 To remove PersonaPicker completely:
 1. Delete the PersonaPicker folder
 2. Remove PersonaPickerView usage from InputBarView.swift (lines 74-80)
 3. Remove menuItemLayout from PersonaUIConfiguration struct and default
 4. Remove menuItemLayout section from PersonaUI.json
 5. The app will continue to work - personas can still be selected by typing their names
 
 NOTES:
 - This atom provides UI-only functionality
 - Core persona management remains in PersonaSystem atom
 - Follows the same pattern as ModelPicker atom
 */