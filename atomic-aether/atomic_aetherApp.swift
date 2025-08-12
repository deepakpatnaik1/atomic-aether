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
    // ATOM 101: EventBus - The nervous system
    @StateObject private var eventBus: EventBus
    
    // ATOM 102: ErrorBus - Centralized error handling
    @StateObject private var errorBus: ErrorBus
    
    // ATOM 103: StateBus - Shared state management
    @StateObject private var stateBus: StateBus
    
    // ATOM 104: ConfigBus - Configuration management
    @StateObject private var configBus = ConfigBus()
    
    // ATOM 201: Model Picker
    @StateObject private var modelPickerService: ModelPickerService
    
    // ATOM 202: LLM System - Models and Services
    @StateObject private var llmRouter: LLMRouter
    @StateObject private var modelRegistry: ModelRegistryService
    
    // ATOM 203: Model Display
    @StateObject private var modelDisplayService: ModelDisplayService
    
    // ATOM 204: Model State
    @StateObject private var modelStateService: ModelStateService
    
    // ATOM 401: Personas - Complete Persona System
    @StateObject private var personaSystem: PersonaSystem
    @StateObject private var personaStateService: PersonaStateService
    
    // ATOM 501: ConversationFlow
    @StateObject private var conversationOrchestrator: ConversationOrchestrator
    
    // ATOM 601: Theme System
    @StateObject private var themeService = ThemeService()
    
    // ATOM 206: Environment Loader
    @StateObject private var envLoader: EnvLoader
    
    // ATOM 503: Message Store
    @StateObject private var messageStore: MessageStore
    
    
    
    // ATOM 207: DevKeys - Development-only API key storage
    @StateObject private var devKeysService: DevKeysService
    
    // ATOM 403: Boss Profile Service
    @StateObject private var bossProfileService: BossProfileService
    
    // ATOM 404: Persona Profile Service
    @StateObject private var personaProfileService: PersonaProfileService
    
    // ATOM 304: Journal Command Service  
    @StateObject private var journalCommandService: JournalCommandService
    
    init() {
        // Create EventBus first (no dependencies)
        let eventBus = EventBus()
        _eventBus = StateObject(wrappedValue: eventBus)
        
        // Create ConfigBus with EventBus dependency
        let configBus = ConfigBus(eventBus: eventBus)
        _configBus = StateObject(wrappedValue: configBus)
        
        // Update EventBus with ConfigBus
        eventBus.configBus = configBus
        
        // Create DevKeysService
        let devKeysService = DevKeysService()
        _devKeysService = StateObject(wrappedValue: devKeysService)
        
        // Create shared instances
        let envLoader = EnvLoader()
        let messageStore = MessageStore()
        
        // Store envLoader as StateObject
        _envLoader = StateObject(wrappedValue: envLoader)
        _messageStore = StateObject(wrappedValue: messageStore)
        
        // Create StateBus with EventBus and ConfigBus
        let stateBus = StateBus(eventBus: eventBus, configBus: configBus)
        _stateBus = StateObject(wrappedValue: stateBus)
        
        // Create ErrorBus with dependencies
        let errorBus = ErrorBus(
            configBus: configBus,
            eventBus: eventBus
        )
        _errorBus = StateObject(wrappedValue: errorBus)
        
        // Create ModelRegistry
        let modelRegistry = ModelRegistryService(
            configBus: configBus,
            eventBus: eventBus
        )
        _modelRegistry = StateObject(wrappedValue: modelRegistry)
        
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
        
        // Create PersonaSystem with all dependencies
        let personaSystem = PersonaSystem(
            configBus: configBus,
            eventBus: eventBus,
            errorBus: errorBus,
            stateBus: stateBus,
            modelStateService: modelStateService
        )
        _personaSystem = StateObject(wrappedValue: personaSystem)
        
        // Get PersonaStateService from PersonaSystem
        let personaStateService = personaSystem.stateService
        _personaStateService = StateObject(wrappedValue: personaStateService)
        
        // Create ConversationOrchestrator with all dependencies
        _conversationOrchestrator = StateObject(wrappedValue: ConversationOrchestrator(
            configBus: configBus,
            eventBus: eventBus,
            errorBus: errorBus,
            stateBus: stateBus,
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
        
        
        
        
        // Create BossProfileService (Phase II)
        _bossProfileService = StateObject(wrappedValue: BossProfileService())
        
        // Create PersonaProfileService (Phase II)
        _personaProfileService = StateObject(wrappedValue: PersonaProfileService())
        
        // Create JournalCommandService
        _journalCommandService = StateObject(wrappedValue: JournalCommandService(
            configBus: configBus,
            eventBus: eventBus,
            stateBus: stateBus
        ))
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
            .environmentObject(personaSystem)
            .environmentObject(stateBus)
            .environmentObject(errorBus)
            .environmentObject(modelStateService)
            .environmentObject(personaStateService)
            .environmentObject(conversationOrchestrator)
            .environmentObject(modelDisplayService)
            .environmentObject(modelPickerService)
            .environmentObject(bossProfileService)
            .environmentObject(personaProfileService)
            .environmentObject(devKeysService)
            .environmentObject(journalCommandService)
            .onAppear {
                // Setup DevKeys service
                devKeysService.setup(configBus: configBus, eventBus: eventBus, errorBus: errorBus, stateBus: stateBus)
                
                // Setup and load environment variables with DevKeys support
                envLoader.setup(configBus: configBus, errorBus: errorBus, eventBus: eventBus, devKeysService: devKeysService)
                envLoader.load()
                
                // Setup PersonaSystem
                personaSystem.setup()
                
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
                
                
                
                
                // Setup BossProfileService (Phase II)
                bossProfileService.setup(configBus: configBus, eventBus: eventBus, errorBus: errorBus)
                
                // Setup PersonaProfileService (Phase II)
                personaProfileService.setup(configBus: configBus, eventBus: eventBus, errorBus: errorBus)
                
                // Setup JournalCommandService
                journalCommandService.setup()
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
