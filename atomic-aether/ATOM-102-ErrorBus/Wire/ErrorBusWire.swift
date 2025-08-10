//
//  ErrorBusWire.swift
//  atomic-aether
//
//  Integration documentation for ErrorBus
//
//  ATOM 102: ErrorBus - Removal and integration instructions
//

/*
 REMOVAL INSTRUCTIONS:
 To remove ErrorBus completely:
 1. Delete ATOM-102-ErrorBus folder
 2. Remove errorBus initialization from atomic_aetherApp.swift (line ~95)
 3. Remove errorBus environment object from atomic_aetherApp.swift (line ~196)
 4. Remove .errorToast() modifier from ContentView.swift (line ~29)
 5. Remove all errorBus.report() calls - errors will be silently ignored
 
 That's it. The app will work perfectly without error display.
 
 INTEGRATION POINTS:
 - atomic_aetherApp.swift: Creates and injects ErrorBus
 - ContentView.swift: Applies .errorToast() view modifier
 - Every atom: Calls errorBus.report() to report errors
 - ConfigBus: ErrorBus loads configuration for auto-dismiss times
 - EventBus: ErrorBus publishes ErrorReported and ErrorCleared events
 
 ERROR REPORTING API:
 ```swift
 errorBus.report(
     message: "Failed to load persona",
     from: "PersonaService",
     severity: .error,
     error: underlyingError  // Optional
 )
 ```
 
 SEVERITY LEVELS:
 - .info: Informational, auto-dismisses quickly (3s)
 - .warning: Warning, moderate dismiss time (5s)
 - .error: Error, longer dismiss time (8s)
 - .critical: Critical, requires manual dismissal
 
 CONFIGURATION (ErrorHandling.json):
 - autoDismissTimes: Dismiss times per severity level
 - maxVisibleErrors: How many toasts to show at once
 - position: Where to show toasts (top, bottom, center)
 - animation: Toast animation settings
 
 BEST PRACTICES:
 - Always provide meaningful error messages
 - Include the source atom name for debugging
 - Use appropriate severity levels
 - Don't spam errors - use throttling if needed
 - Consider if the error needs user attention
 */