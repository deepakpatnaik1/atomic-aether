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
    @StateObject private var envLoader = EnvLoader()
    
    // ATOM 8: LLM Services
    @StateObject private var llmRouter: LLMRouter
    
    // ATOM 9: Scrollback Message Area
    @StateObject private var messageStore = MessageStore()
    @StateObject private var personaService = PersonaService()
    
    init() {
        // Create EventBus first (no dependencies)
        let eventBus = EventBus()
        _eventBus = StateObject(wrappedValue: eventBus)
        
        // Create EventLogger with EventBus
        _eventLogger = StateObject(wrappedValue: EventLogger(eventBus: eventBus))
        
        // Create core services needed by LLMRouter
        let envLoader = EnvLoader()
        let configBus = ConfigBus()
        
        // Create LLMRouter with dependencies
        _llmRouter = StateObject(wrappedValue: LLMRouter(
            envLoader: envLoader,
            configBus: configBus,
            eventBus: eventBus
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
            .onAppear {
                // Load environment variables
                envLoader.load()
                
                // Setup LLM services after environment is loaded
                Task {
                    try? await Task.sleep(nanoseconds: 100_000_000) // Small delay for env loading
                    llmRouter.setupServices()
                }
            }
        }
    }
}
