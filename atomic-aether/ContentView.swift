//
//  ContentView.swift
//  atomic-aether
//
//  Created by Deepak Patnaik on 29.07.25.
//
//  ATOM 1: Black Background - Basic app structure with dark theme
//  ATOM 6: ConfigBus - Wires up configuration services
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var themeService: ThemeService
    @EnvironmentObject var configBus: ConfigBus
    
    var body: some View {
        VStack {
            Spacer()
            
            // Input Bar
            InputBarView()
        }
        .onAppear {
            // Setup services with ConfigBus
            themeService.setupWithConfigBus(configBus)
        }
    }
}

#Preview {
    ContentView()
}
