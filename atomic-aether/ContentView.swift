//
//  ContentView.swift
//  atomic-aether
//
//  Created by Deepak Patnaik on 29.07.25.
//
//  Main app view with dark theme
//  ATOM 104: ConfigBus - Wires up configuration services
//  ATOM 502: Scrollback - Displays messages
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var themeService: ThemeService
    @EnvironmentObject var configBus: ConfigBus
    @EnvironmentObject var messageStore: MessageStore
    @EnvironmentObject var errorBus: ErrorBus
    @EnvironmentObject var stateBus: StateBus
    
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                // Scrollback
                ScrollbackView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                
                // Input Bar
                InputBarView()
            }
            .errorToast() // ATOM 102: ErrorBus toast overlay
            .onAppear {
                // Setup services with ConfigBus
                themeService.setupWithConfigBus(configBus)
                
                // Calculate responsive width from configuration
                if let inputConfig = configBus.load("InputBarAppearance", as: InputBarAppearance.self) {
                    let width = max(
                        geometry.size.width * inputConfig.dimensions.widthRatio,
                        inputConfig.dimensions.minWidth
                    )
                    stateBus.set(StateKey.contentWidth, value: width)
                }
            }
            .onChange(of: geometry.size.width) {
                // Update width when window resizes
                if let inputConfig = configBus.load("InputBarAppearance", as: InputBarAppearance.self) {
                    let width = max(
                        geometry.size.width * inputConfig.dimensions.widthRatio,
                        inputConfig.dimensions.minWidth
                    )
                    stateBus.set(StateKey.contentWidth, value: width)
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
