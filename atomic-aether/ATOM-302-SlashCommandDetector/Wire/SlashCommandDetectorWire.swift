//
//  SlashCommandDetectorWire.swift
//  atomic-aether
//
//  Integration documentation for Slash Command Detector
//
//  ATOM 302: Slash Command Detector - Removal and integration instructions
//

/*
 REMOVAL INSTRUCTIONS:
 To remove Slash Command Detector completely:
 1. Delete ATOM-302-SlashCommandDetector folder
 2. Remove slashCommandDetector initialization from InputBarView.swift (line ~19)
 3. Remove slashCommandDetector.setupWithBuses() from InputBarView.swift (line ~46)
 4. Remove slashCommandDetector.handleTextChange() calls from InputBarView.swift (lines ~151, ~183)
 5. Remove slashCommandDetector.isExpanded checks from InputBarView.swift (line ~138)
 6. Remove slashCommandDetector.shouldAllowCollapse() from InputBarView.swift (lines ~161, ~193)
 7. Remove .onKeyPress(.escape) handlers from InputBarView.swift (lines ~159, ~191)
 8. Remove expandToLines calculation from InputBarView.swift (line ~128)
 
 Without this atom, slash commands won't work and input won't expand.
 
 INTEGRATION POINTS:
 - InputBarView: Main integration point for command detection
 - ConfigBus: Loads SlashCommandDetector.json configuration
 - EventBus: Publishes SlashCommandEvent events
 - TextEditor: Expands based on activeCommand.expandToLines
 
 SERVICE ARCHITECTURE:
 SlashCommandDetector provides:
 - Command detection from text input
 - Expansion state management
 - Collapse condition checking
 - Event publishing for command lifecycle
 
 CONFIGURATION (SlashCommandDetector.json):
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
     }
   ],
   "detectCaseSensitive": false,
   "clearTextOnExpand": true
 }
 ```
 
 DETECTION FLOW:
 1. User types in TextEditor
 2. handleTextChange() called on each keystroke
 3. detectCommand() checks if text matches any trigger
 4. If match found:
    - Publishes commandDetected event
    - Sets activeCommand and isExpanded
    - Returns true to clear text (if configured)
 5. TextEditor expands to specified lines
 
 EXPANSION LOGIC:
 ```swift
 let maxLines = slashCommandDetector.activeCommand?.expandToLines ?? appearance.multiline.maxLines
 ```
 
 COLLAPSE LOGIC:
 - Escape key pressed
 - shouldAllowCollapse() checks:
   - activeCommand exists
   - text is empty
   - isExpanded is true
 - collapse() clears state
 
 EVENTS PUBLISHED:
 - SlashCommandEvent.commandDetected(command)
 - SlashCommandEvent.commandExpanded(command, lines)
 - SlashCommandEvent.commandCollapsed
 - SlashCommandEvent.commandExecuted(command, text)
 - InputEvent.slashCommandEntered (legacy compatibility)
 
 ADDING NEW COMMANDS:
 1. Add to commands array in JSON
 2. Set trigger (e.g., "/code")
 3. Set expandToLines (null = no expansion)
 4. Add description for help
 
 STATE MANAGEMENT:
 - activeCommand: Currently detected command
 - isExpanded: Whether input is expanded
 - configuration: Loaded from JSON
 
 BEST PRACTICES:
 - Commands should start with /
 - Use lowercase triggers with case-insensitive detection
 - Provide clear descriptions
 - Test expansion/collapse flow
 - Consider mobile keyboard behavior
 */