//
//  atomic_aetherApp.swift
//  atomic-aether
//
//  Created by Deepak Patnaik on 29.07.25.
//

import SwiftUI

@main
struct atomic_aetherApp: App {
    // Atom 1: Dark Theme service
    @StateObject private var themeService = ThemeService()
    
    var body: some Scene {
        WindowGroup {
            ThemedContainer {
                ContentView()
            }
            .environmentObject(themeService)
        }
    }
}
