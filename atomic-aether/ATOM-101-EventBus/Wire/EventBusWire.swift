//
//  EventBusWire.swift
//  atomic-aether
//
//  Integration documentation for EventBus
//
//  ATOM 101: EventBus - Removal and integration instructions
//

/*
 REMOVAL INSTRUCTIONS:
 To remove EventBus completely:
 1. Delete ATOM-101-EventBus folder
 2. Remove eventBus initialization from atomic_aetherApp.swift (line ~73)
 3. Remove eventBus environment object from atomic_aetherApp.swift (line ~189)
 4. Replace all eventBus.publish() calls with direct method calls
 5. Remove all eventBus.subscribe() calls and replace with direct dependencies
 
 WARNING: Removing EventBus breaks the Atomic LEGO architecture.
 Atoms will need to directly import and couple to each other.
 
 INTEGRATION POINTS:
 - atomic_aetherApp.swift: Creates and injects EventBus
 - Every atom: Uses eventBus.publish() to send events
 - Every atom: Uses eventBus.subscribe() to receive events
 - ConfigBus: EventBus depends on ConfigBus for hot-reload configuration
 
 EVENT CATEGORIES:
 - SystemEvents: App lifecycle (launch, terminate, background)
 - ConversationEvents: Message flow (started, completed, error)
 - InputEvents: User input (text changed, persona detected, slash command)
 - NavigationEvents: UI navigation (view changed, modal presented)
 - PersonaEvents: Persona system (switched, detected, loaded)
 - ModelEvents: Model selection (selected, changed, loaded)
 - ConfigEvents: Configuration changes (loaded, updated, error)
 - ErrorEvents: Error notifications (reported, cleared)
 
 BEST PRACTICES:
 - Always use weak self in closures to prevent retain cycles
 - Store subscriptions in cancellables for proper cleanup
 - Define events as enums with associated values for type safety
 - Keep events focused - don't create kitchen sink events
 - Document each event's purpose and expected listeners
 */