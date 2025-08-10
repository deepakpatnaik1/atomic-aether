//
//  ScrollbackWire.swift
//  atomic-aether
//
//  Integration documentation for Scrollback atom
//
//  ATOM 502: Scrollback - Removal and integration instructions
//

/*
 REMOVAL INSTRUCTIONS:
 To remove Scrollback completely:
 1. Delete ATOM-502-Scrollback folder
 2. Remove ScrollbackView from ContentView.swift (line ~15)
 3. Remove scrollbackCoordinator initialization from atomic_aetherApp.swift (line ~155)
 4. Remove scrollbackCoordinator environment object from atomic_aetherApp.swift (line ~198)
 5. Delete aetherVault/Config/ScrollbackAppearance.json
 
 WARNING: Without Scrollback, messages won't be displayed.
 You'll need an alternative UI for viewing conversations.
 
 INTEGRATION POINTS:
 - ContentView.swift: Contains ScrollbackView as main display
 - MessageStore: Provides messages to display
 - ConfigBus: Loads ScrollbackAppearance.json
 - ScrollbackCoordinator: Manages scrollback state
 
 ARCHITECTURE:
 ScrollbackView is the main container that:
 - Observes MessageStore for message updates
 - Filters empty messages (unless streaming)
 - Displays MessageRow for each message
 - Shows SpeakerLabel with persona colors
 
 CONFIGURATION (ScrollbackAppearance.json):
 ```json
 {
   "layout": {
     "maxWidth": 700,
     "spacing": 16,
     "messageGroupSpacing": 8
   },
   "speakerLabel": {
     "borderWidth": 1,
     "borderOpacity": 0.8,
     "fontSize": 13,
     "padding": 8
   },
   "messageContent": {
     "fontSize": 15,
     "lineSpacing": 1.2,
     "selectionColor": "#3B82F6"
   }
 }
 ```
 
 MESSAGE STRUCTURE:
 ```swift
 struct Message {
     let id: UUID
     let speaker: String      // "Boss", "Claude", etc.
     let content: String      // Markdown content
     let timestamp: Date
     let isStreaming: Bool    // Shows progress indicator
     let modelUsed: String?   // Optional model display
 }
 ```
 
 SPEAKER LABEL VISUALS:
 ```
 ┌─────────────┐━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 │   Claude    │  (Colored border + gradient line)
 └─────────────┘
 ```
 
 STREAMING BEHAVIOR:
 - Empty messages hidden unless isStreaming = true
 - Progress indicator shows during streaming
 - Automatic scroll to bottom on new messages
 - Smooth transitions when streaming completes
 
 MESSAGE GROUPING:
 - Consecutive messages from same speaker grouped
 - First message shows full speaker label
 - Subsequent messages have reduced spacing
 - New speaker triggers full label again
 
 EMPTY MESSAGE FILTERING:
 ```swift
 messages.filter { message in
     !message.content.isEmpty || message.isStreaming
 }
 ```
 
 PERSONA COLORS:
 - Each persona has unique color in JSON
 - Falls back to default if not specified
 - Used for border and gradient line
 - Consistent with PersonaIndicator colors
 
 BEST PRACTICES:
 - Keep messages under 5000 chars for performance
 - Use markdown for rich formatting
 - Test with long conversations (100+ messages)
 - Ensure smooth scrolling on all platforms
 - Monitor memory usage with large histories
 */