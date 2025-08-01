//
//  atomic_aetherApp.swift
//  atomic-aether
//
//  Created by Deepak Patnaik on 29.07.25.
//

import SwiftUI

@main
struct atomic_aetherApp: App {
    // ATOM 1: Dark Theme service
    @StateObject private var themeService = ThemeService()
    
    // ATOM 5: EventBus - The nervous system
    @StateObject private var eventBus: EventBus
    @StateObject private var eventLogger: EventLogger
    
    // ATOM 6: ConfigBus - Configuration management
    @StateObject private var configBus = ConfigBus()
    
    // ATOM 7: Environment Configuration
    @StateObject private var envLoader: EnvLoader
    
    // ATOM 8: LLM Services
    @StateObject private var llmRouter: LLMRouter
    
    // ATOM 9: Scrollback Message Area
    @StateObject private var messageStore = MessageStore()
    @StateObject private var personaService = PersonaService()
    
    // ATOM 10: StateBus - Shared state management
    @StateObject private var stateBus: StateBus
    
    // ATOM 11: ErrorBus - Centralized error handling
    @StateObject private var errorBus: ErrorBus
    
    // ATOM 12: Model State Management
    @StateObject private var modelStateService: ModelStateService
    
    init() {
        // Create EventBus first (no dependencies)
        let eventBus = EventBus()
        _eventBus = StateObject(wrappedValue: eventBus)
        
        // Create EventLogger with EventBus
        _eventLogger = StateObject(wrappedValue: EventLogger(eventBus: eventBus))
        
        // Create shared instances
        let envLoader = EnvLoader()
        let configBus = ConfigBus()
        
        // Store envLoader as StateObject
        _envLoader = StateObject(wrappedValue: envLoader)
        _configBus = StateObject(wrappedValue: configBus)
        
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
        _modelStateService = StateObject(wrappedValue: ModelStateService(
            configBus: configBus,
            stateBus: stateBus,
            eventBus: eventBus,
            errorBus: errorBus,
            llmRouter: llmRouter
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
            .environmentObject(eventLogger)
            .environmentObject(envLoader)
            .environmentObject(llmRouter)
            .environmentObject(messageStore)
            .environmentObject(personaService)
            .environmentObject(stateBus)
            .environmentObject(errorBus)
            .environmentObject(modelStateService)
            .onAppear {
                // Load environment variables
                envLoader.load()
                
                // Setup services with ConfigBus
                personaService.setupWithConfigBus(configBus)
                
                // Setup ErrorBus configuration
                errorBus.setupConfiguration()
                
                // Setup LLM services immediately after environment is loaded
                // The environment loading is synchronous, so it's ready now
                llmRouter.setupServices()
            }
        }
    }
}
