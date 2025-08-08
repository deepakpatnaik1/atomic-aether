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
    // ATOM 19: Theme System
    @StateObject private var themeService = ThemeService()
    
    // ATOM 1: EventBus - The nervous system
    @StateObject private var eventBus: EventBus
    
    // ATOM 4: ConfigBus - Configuration management
    @StateObject private var configBus = ConfigBus()
    
    // ATOM 20: Environment Loader
    @StateObject private var envLoader: EnvLoader
    
    // ATOM 18: LLM Services
    @StateObject private var llmRouter: LLMRouter
    
    // ATOM 9: Models - Model Registry
    @StateObject private var modelRegistry: ModelRegistryService
    
    // ATOM 10: Personas - Complete Persona System
    @StateObject private var personaSystem: PersonaSystem
    
    // ATOM 21: Message Store
    @StateObject private var messageStore: MessageStore
    
    // ATOM 3: StateBus - Shared state management
    @StateObject private var stateBus: StateBus
    
    // ATOM 2: ErrorBus - Centralized error handling
    @StateObject private var errorBus: ErrorBus
    
    // ATOM 17: Model State
    @StateObject private var modelStateService: ModelStateService
    
    // ATOM 10: Personas - State Service
    @StateObject private var personaStateService: PersonaStateService
    
    // ATOM 14: ConversationFlow
    @StateObject private var conversationOrchestrator: ConversationOrchestrator
    
    // ATOM 16: Model Display
    @StateObject private var modelDisplayService: ModelDisplayService
    
    // ATOM 8: Model Picker
    @StateObject private var modelPickerService: ModelPickerService
    
    // ATOM 22: Response Parser (Phase II)
    @StateObject private var responseParserService: ResponseParserService
    
    // ATOM 24: Journal Service (Phase II)
    @StateObject private var journalService: JournalService
    
    // ATOM 25: SuperJournal Service (Phase II)
    @StateObject private var superJournalService: SuperJournalService
    
    // ATOM 26: Boss Profile Service (Phase II)
    @StateObject private var bossProfileService: BossProfileService
    
    // ATOM 27: Persona Profile Service (Phase II)
    @StateObject private var personaProfileService: PersonaProfileService
    
    // ATOM 28: System Prompt Builder (Phase II)
    @StateObject private var systemPromptBuilder: SystemPromptBuilderService
    
    // ATOM 29: Machine Trim Instructions (Phase II)
    @StateObject private var machineTrimInstructionsService: MachineTrimInstructionsService
    
    // ATOM 30: Scrollback History Loader (Phase II)
    @StateObject private var scrollbackHistoryLoader: ScrollbackHistoryLoaderService
    
    // ATOM: DevKeys - Development-only API key storage
    @StateObject private var devKeysService: DevKeysService
    
    
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
        
        // Create SuperJournalService (Phase II)
        _superJournalService = StateObject(wrappedValue: SuperJournalService())
        
        // Create BossProfileService (Phase II)
        _bossProfileService = StateObject(wrappedValue: BossProfileService())
        
        // Create PersonaProfileService (Phase II)
        _personaProfileService = StateObject(wrappedValue: PersonaProfileService())
        
        // Create SystemPromptBuilder (Phase II)
        _systemPromptBuilder = StateObject(wrappedValue: SystemPromptBuilderService())
        
        // Create MachineTrimInstructionsService (Phase II)
        _machineTrimInstructionsService = StateObject(wrappedValue: MachineTrimInstructionsService())
        
        // Create ScrollbackHistoryLoaderService (Phase II)
        _scrollbackHistoryLoader = StateObject(wrappedValue: ScrollbackHistoryLoaderService())
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
            .environmentObject(responseParserService)
            .environmentObject(journalService)
            .environmentObject(superJournalService)
            .environmentObject(bossProfileService)
            .environmentObject(personaProfileService)
            .environmentObject(systemPromptBuilder)
            .environmentObject(scrollbackHistoryLoader)
            .environmentObject(devKeysService)
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
                
                // Setup ResponseParserService (Phase II)
                responseParserService.setup(configBus: configBus, eventBus: eventBus)
                conversationOrchestrator.setResponseParser(responseParserService)
                
                // Wire SystemPromptBuilder to ConversationOrchestrator (Phase II)
                conversationOrchestrator.setSystemPromptBuilder(systemPromptBuilder)
                
                // Setup JournalService (Phase II)
                journalService.setup(configBus: configBus, eventBus: eventBus, errorBus: errorBus)
                
                // Setup SuperJournalService (Phase II)
                superJournalService.setup(configBus: configBus, eventBus: eventBus, errorBus: errorBus)
                
                // Setup BossProfileService (Phase II)
                bossProfileService.setup(configBus: configBus, eventBus: eventBus, errorBus: errorBus)
                
                // Setup PersonaProfileService (Phase II)
                personaProfileService.setup(configBus: configBus, eventBus: eventBus, errorBus: errorBus)
                
                // Setup MachineTrimInstructionsService (Phase II)
                machineTrimInstructionsService.setup(
                    configBus: configBus,
                    eventBus: eventBus,
                    errorBus: errorBus,
                    personaStateService: personaStateService
                )
                
                // Setup SystemPromptBuilder (Phase II)
                systemPromptBuilder.setup(
                    configBus: configBus,
                    eventBus: eventBus,
                    personaStateService: personaStateService,
                    bossProfileService: bossProfileService,
                    personaProfileService: personaProfileService,
                    journalService: journalService,
                    machineTrimInstructionsService: machineTrimInstructionsService
                )
                
                // Setup ScrollbackHistoryLoader (Phase II)
                scrollbackHistoryLoader.setup(
                    configBus: configBus,
                    eventBus: eventBus,
                    errorBus: errorBus,
                    messageStore: messageStore
                )
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
