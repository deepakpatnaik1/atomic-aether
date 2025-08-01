//
//  ContentView.swift
//  atomic-aether
//
//  Created by Deepak Patnaik on 29.07.25.
//
//  ATOM 1: Black Background - Basic app structure with dark theme
//  ATOM 6: ConfigBus - Wires up configuration services
//  ATOM 9: Scrollback Message Area - Displays messages
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var themeService: ThemeService
    @EnvironmentObject var configBus: ConfigBus
    @EnvironmentObject var messageStore: MessageStore
    @EnvironmentObject var errorBus: ErrorBus
    
    var body: some View {
        VStack(spacing: 0) {
            // Top bar with persona indicator
            HStack {
                PersonaIndicator()
                    .padding(.leading)
                
                Spacer()
            }
            .padding(.vertical, 8)
            .background(themeService.current.backgroundColor.opacity(0.8))
            
            // Scrollback
            ScrollbackView()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            // Input Bar
            InputBarView()
        }
        .errorToast() // ATOM 11: ErrorBus toast overlay
        .onAppear {
            // Setup services with ConfigBus
            themeService.setupWithConfigBus(configBus)
            
            // Add test messages
            #if DEBUG
            addTestMessages()
            #endif
        }
    }
    
    #if DEBUG
    private func addTestMessages() {
        messageStore.addMessage(Message(
            speaker: "boss",
            content: "Hello! Let's test the LLM integration."
        ))
        
        messageStore.addMessage(Message(
            speaker: "system",
            content: "Hi there! I'm ready to help. This is a test response from the System persona.",
            modelUsed: "openai:gpt-4o"
        ))
        
        messageStore.addMessage(Message(
            speaker: "boss",
            content: "Can you explain quantum computing?"
        ))
        
        messageStore.addMessage(Message(
            speaker: "system",
            content: "Quantum computing uses quantum mechanics principles like superposition and entanglement to process information in fundamentally different ways than classical computers...",
            isStreaming: true,
            modelUsed: "anthropic:claude-sonnet-4"
        ))
    }
    #endif
}

#Preview {
    ContentView()
}
