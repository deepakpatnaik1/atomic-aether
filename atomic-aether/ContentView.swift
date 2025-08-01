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
        }
    }
}

#Preview {
    ContentView()
}
