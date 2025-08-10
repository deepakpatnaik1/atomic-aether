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
 2. Remove journalCommandService initialization from atomic_aetherApp.swift
 3. Remove journalCommandService environment object from atomic_aetherApp.swift
 4. Remove "/journal" command from SlashCommandDetector.json
 5. Delete aetherVault/Config/JournalCommand.json
 
 The app will continue to work but /journal will have no special behavior.
 
 INTEGRATION POINTS:
 - SlashCommandDetector: Detects "/journal" and publishes event
 - JournalCommandService: Listens for slash command events
 - InputBar: Expands based on StateBus values
 - EventBus: Coordinates command detection and execution
 - StateBus: Shares expansion state with InputBar
 
 ARCHITECTURE:
 JournalCommand enhances the /journal slash command with:
 1. Configurable text expansion (default: 34 lines)
 2. Auto-insert journal entry prefix
 3. Date/time stamp insertion
 4. Cursor positioning control
 5. Event notifications for tracking
 
 CONFIGURATION (JournalCommand.json):
 ```json
 {
   "expandToLines": 34,
   "clearTextOnExpand": true,
   "autoInsertPrefix": true,
   "prefixTemplate": "## Journal Entry - {date}",
   "dateFormat": "EEEE, MMMM d, yyyy",
   "insertCursorPosition": "newLine",
   "enableTimestamp": true,
   "timestampFormat": "HH:mm"
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
 Expands input via StateBus
        ↓
 Inserts prefix via InputEvent
        ↓
 User writes journal entry
 ```
 
 PREFIX TEMPLATES:
 - "{date}" → Replaced with formatted date
 - "## Journal Entry" → Static header
 - Custom templates supported
 
 CURSOR POSITIONS:
 - afterPrefix: Right after prefix text
 - newLine: On new line after prefix
 - end: Multiple lines after prefix
 
 EVENTS PUBLISHED:
 - JournalCommandTriggered: Command detected
 - JournalCommandExpanded: Input expanded
 - JournalCommandCompleted: Entry submitted
 
 EXAMPLE OUTPUT:
 ```
 ## Journal Entry - Thursday, August 10, 2025 - 14:30
 
 [cursor here]
 ```
 
 FUTURE ENHANCEMENTS:
 - Journal entry templates
 - Mood/category selection
 - Auto-save to journal file
 - Entry preview formatting
 - Voice dictation trigger
 
 WHY SEPARATE FROM DETECTOR:
 - SlashCommandDetector: Generic detection
 - JournalCommand: Specific behavior
 - Allows other commands without coupling
 - Each command can have own atom
 - Clean separation of concerns
 */