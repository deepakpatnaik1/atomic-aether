//
//  InputBarAppearanceService.swift
//  atomic-aether
//
//  Service to load input bar appearance configuration
//
//  Atomic LEGO: Loads appearance from JSON
//  Simple service, no complex logic
//

import Foundation
import SwiftUI

class InputBarAppearanceService: ObservableObject {
    @Published var appearance: InputBarAppearance?
    @Published var loadError: String?
    
    init() {
        loadAppearance()
    }
    
    private func loadAppearance() {
        // Look for the JSON file in the bundle
        guard let url = Bundle.main.url(forResource: "InputBarAppearance", withExtension: "json") else {
            print("⚠️ InputBarAppearance.json not found in bundle - using fallback")
            loadError = "InputBarAppearance.json not found in bundle"
            // Provide a default appearance as fallback
            appearance = createDefaultAppearance()
            return
        }
        
        do {
            let data = try Data(contentsOf: url)
            appearance = try JSONDecoder().decode(InputBarAppearance.self, from: data)
            print("✅ Successfully loaded InputBarAppearance.json")
        } catch {
            print("❌ Failed to decode InputBarAppearance.json: \(error)")
            loadError = "Failed to load InputBarAppearance: \(error)"
            // Provide a default appearance as fallback
            appearance = createDefaultAppearance()
        }
    }
    
    // Fallback appearance matching our JSON structure
    private func createDefaultAppearance() -> InputBarAppearance {
        InputBarAppearance(
            dimensions: .init(
                width: 592,
                defaultHeight: 104,
                bottomMargin: 16,
                textFieldMinHeight: 22,
                cornerRadius: 12
            ),
            padding: .init(
                uniform: 22,
                horizontal: 20
            ),
            glassmorphic: .init(
                backgroundOpacity: 0.85,
                borderTopOpacity: 0.3,
                borderBottomOpacity: 0.1,
                blurRadius: 20
            ),
            shadows: .init(
                outer: .init(color: "black", opacity: 0.4, radius: 12, x: 0, y: 4),
                inner: .init(color: "white", opacity: 0.08, radius: 8, x: 0, y: -2)
            ),
            textField: .init(
                textColor: "white",
                fontSize: 14,
                fontFamily: "System"
            ),
            multiline: .init(
                enabled: true,
                maxLines: 10,
                lineHeight: 22
            ),
            controls: .init(
                spacing: 12,
                plusButton: .init(iconName: "plus", size: 16, opacity: 0.7),
                modelPicker: .init(text: "Claude 3.5 Sonnet", fontSize: 12, opacity: 0.7),
                greenIndicator: .init(size: 8, color: "green", glowRadius1: 4, glowRadius2: 8, glowOpacity: 0.5)
            )
        )
    }
}