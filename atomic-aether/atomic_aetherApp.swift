//
//  atomic_aetherApp.swift
//  atomic-aether
//
//  Created by Deepak Patnaik on 29.07.25.
//

import SwiftUI
import AppKit

@main
struct atomic_aetherApp: App {
    // ATOM 1: Dark Theme service
    @StateObject private var themeService = ThemeService()
    
    // ATOM 5: EventBus - The nervous system
    @StateObject private var eventBus: EventBus
    
    // ATOM 6: ConfigBus - Configuration management
    @StateObject private var configBus = ConfigBus()
    
    // ATOM 7: Environment Configuration
    @StateObject private var envLoader: EnvLoader
    
    // ATOM 8: LLM Services
    @StateObject private var llmRouter: LLMRouter
    
    // ATOM 9: Scrollback Message Area
    @StateObject private var messageStore: MessageStore
    @StateObject private var personaService = PersonaService()
    
    // ATOM 10: StateBus - Shared state management
    @StateObject private var stateBus: StateBus
    
    // ATOM 11: ErrorBus - Centralized error handling
    @StateObject private var errorBus: ErrorBus
    
    // ATOM 12: Model State Management
    @StateObject private var modelStateService: ModelStateService
    
    // ATOM 13: Persona System
    @StateObject private var personaStateService: PersonaStateService
    
    // ATOM 15: Conversation Flow
    @StateObject private var conversationOrchestrator: ConversationOrchestrator
    
    // ATOM 18: Dynamic Model Display
    @StateObject private var modelDisplayService: ModelDisplayService
    
    // ATOM 19: Interactive Model Picker
    @StateObject private var modelPickerService: ModelPickerService
    
    // ATOM 23: Response Parser (Phase II)
    @StateObject private var responseParserService: ResponseParserService
    
    // ATOM 24: Journal Service (Phase II)
    @StateObject private var journalService: JournalService
    
    init() {
        // Create EventBus first (no dependencies)
        let eventBus = EventBus()
        _eventBus = StateObject(wrappedValue: eventBus)
        
        // Create shared instances
        let envLoader = EnvLoader()
        let configBus = ConfigBus()
        let messageStore = MessageStore()
        
        // Store envLoader as StateObject
        _envLoader = StateObject(wrappedValue: envLoader)
        _configBus = StateObject(wrappedValue: configBus)
        _messageStore = StateObject(wrappedValue: messageStore)
        
        // Create StateBus with EventBus
        let stateBus = StateBus(eventBus: eventBus)
        _stateBus = StateObject(wrappedValue: stateBus)
        
        // Create ErrorBus with dependencies
        let errorBus = ErrorBus(
            configBus: configBus,
            eventBus: eventBus
        )
        _errorBus = StateObject(wrappedValue: errorBus)
        
        // Create LLMRouter with the same envLoader instance
        let llmRouter = LLMRouter(
            envLoader: envLoader,
            configBus: configBus,
            eventBus: eventBus
        )
        _llmRouter = StateObject(wrappedValue: llmRouter)
        
        // Create ModelStateService with all dependencies
        let modelStateService = ModelStateService(
            configBus: configBus,
            stateBus: stateBus,
            eventBus: eventBus,
            errorBus: errorBus,
            llmRouter: llmRouter
        )
        _modelStateService = StateObject(wrappedValue: modelStateService)
        
        // Create PersonaStateService with all dependencies
        let personaStateService = PersonaStateService(
            configBus: configBus,
            stateBus: stateBus,
            eventBus: eventBus,
            errorBus: errorBus,
            modelStateService: modelStateService
        )
        _personaStateService = StateObject(wrappedValue: personaStateService)
        
        // Create ConversationOrchestrator with all dependencies
        _conversationOrchestrator = StateObject(wrappedValue: ConversationOrchestrator(
            configBus: configBus,
            eventBus: eventBus,
            errorBus: errorBus,
            personaStateService: personaStateService,
            llmRouter: llmRouter,
            messageStore: messageStore
        ))
        
        // Create ModelDisplayService with dependencies
        let modelDisplayService = ModelDisplayService(
            configBus: configBus,
            eventBus: eventBus,
            modelStateService: modelStateService,
            personaStateService: personaStateService
        )
        _modelDisplayService = StateObject(wrappedValue: modelDisplayService)
        
        // Create ModelPickerService with dependencies
        _modelPickerService = StateObject(wrappedValue: ModelPickerService(
            configBus: configBus,
            modelStateService: modelStateService,
            modelDisplayService: modelDisplayService,
            personaStateService: personaStateService
        ))
        
        // Create ResponseParserService (Phase II)
        _responseParserService = StateObject(wrappedValue: ResponseParserService())
        
        // Create JournalService (Phase II)
        _journalService = StateObject(wrappedValue: JournalService())
    }
    
    var body: some Scene {
        WindowGroup {
            ThemedContainer {
                ContentView()
            }
            .environmentObject(themeService)
            .environmentObject(eventBus)
            .environmentObject(configBus)
            .environmentObject(envLoader)
            .environmentObject(llmRouter)
            .environmentObject(messageStore)
            .environmentObject(personaService)
            .environmentObject(stateBus)
            .environmentObject(errorBus)
            .environmentObject(modelStateService)
            .environmentObject(personaStateService)
            .environmentObject(conversationOrchestrator)
            .environmentObject(modelDisplayService)
            .environmentObject(modelPickerService)
            .environmentObject(responseParserService)
            .environmentObject(journalService)
            .onAppear {
                // Setup and load environment variables
                envLoader.setup(configBus: configBus, errorBus: errorBus)
                envLoader.load()
                
                // Setup services with ConfigBus
                personaService.setupWithConfigBus(configBus)
                
                // Setup ErrorBus configuration
                errorBus.setupConfiguration()
                
                // Setup MessageStore
                messageStore.setup(configBus: configBus, eventBus: eventBus)
                
                // Setup LLM services immediately after environment is loaded
                // The environment loading is synchronous, so it's ready now
                llmRouter.setupServices()
                
                // Setup ModelStateService after view is ready
                modelStateService.setup()
                
                // Setup PersonaStateService after view is ready
                personaStateService.setup()
                
                // Setup ConversationOrchestrator after view is ready
                conversationOrchestrator.setup()
                
                // Setup ModelDisplayService after view is ready
                modelDisplayService.setup()
                
                // Setup ModelPickerService after view is ready
                modelPickerService.setup()
                
                // Setup ResponseParserService (Phase II)
                responseParserService.setup(configBus: configBus, eventBus: eventBus)
                conversationOrchestrator.setResponseParser(responseParserService)
                
                // Setup JournalService (Phase II)
                journalService.setup(configBus: configBus, eventBus: eventBus, errorBus: errorBus)
            }
        }
        .commands {
            // Add Settings menu
            CommandGroup(after: .appSettings) {
                Button("API Keys...") {
                    openAPIKeySetup()
                }
                .keyboardShortcut(",", modifiers: [.command, .shift])
            }
        }
    }
    
    private func openAPIKeySetup() {
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 400, height: 400),
            styleMask: [.titled, .closable, .miniaturizable],
            backing: .buffered,
            defer: false
        )
        window.title = "API Key Setup"
        window.center()
        window.isReleasedWhenClosed = false
        
        let hostingView = NSHostingView(
            rootView: APIKeySetupView()
                .environmentObject(envLoader)
        )
        window.contentView = hostingView
        window.makeKeyAndOrderFront(nil)
    }
}
