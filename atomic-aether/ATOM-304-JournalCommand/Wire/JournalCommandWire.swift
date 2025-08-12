//
//  JournalCommandWire.swift
//  atomic-aether
//
//  Integration documentation for Journal Command
//
//  ATOM 304: JournalCommand - Removal and integration instructions
//

/*
 REMOVAL INSTRUCTIONS:
 To remove JournalCommand completely:
 1. Delete ATOM-304-JournalCommand folder
 2. Remove journalCommandService initialization from atomic_aetherApp.swift (line ~180)
 3. Remove journalCommandService environment object from atomic_aetherApp.swift (line ~209)
 4. Delete aetherVault/Config/JournalCommand.json
 
 The app will continue to work with basic /journal expansion from SlashCommandDetector.
 
 INTEGRATION POINTS:
 - SlashCommandDetector: Detects "/journal" and publishes event
 - JournalCommandService: Listens for slash command events
 - EventBus: Coordinates command detection and execution
 - StateBus: Sets expandedLines for InputBar
 
 ARCHITECTURE:
 JournalCommand handles the /journal slash command with:
 1. Text expansion to 42 lines
 2. Esc key handling (via InputBar)
 3. Event notifications for tracking
 
 CONFIGURATION (JournalCommand.json):
 ```json
 {
   "trigger": "/journal",
   "expandToLines": 42,
   "clearTextOnExpand": true
 }
 ```
 
 COMMAND FLOW:
 ```
 User types "/journal"
        ↓
 SlashCommandDetector detects
        ↓
 Publishes SlashCommandEvent
        ↓
 JournalCommandService receives event
        ↓
 Sets expandedLines in StateBus
        ↓
 InputBar expands
        ↓
 User writes journal entry
        ↓
 Esc key collapses (handled by InputBar)
 ```
 
 EVENTS PUBLISHED:
 - JournalCommandTriggered: Command detected
 - JournalCommandExpanded: Input expanded
 
 WHY SEPARATE FROM DETECTOR:
 - SlashCommandDetector: Universal detection for all commands
 - JournalCommand: Specific behavior for /journal
 - Allows future commands to have their own atoms
 - Clean separation of concerns
 - Follows atomic LEGO architecture
 */