//
//  InputBarAppearanceService.swift
//  atomic-aether
//
//  Service to manage input bar appearance configuration
//
//  ATOM 301: Input Bar - Appearance configuration service
//  Uses ConfigBus (ATOM 104) for hot-reloading
//
//  Atomic LEGO: Subscribes to configuration changes
//  Zero coupling to configuration loading details
//

import Foundation
import SwiftUI
import Combine

@MainActor
class InputBarAppearanceService: ObservableObject {
    @Published var appearance: InputBarAppearance?
    
    private var configBus: ConfigBus?
    private var cancellable: AnyCancellable?
    
    init() {
        // Will be injected via setupWithConfigBus
    }
    
    /// Setup with ConfigBus for hot-reloading support
    func setupWithConfigBus(_ configBus: ConfigBus) {
        self.configBus = configBus
        
        // Initial load - no fallback
        appearance = configBus.load("InputBarAppearance", as: InputBarAppearance.self)
        
        // Watch for changes
        cancellable = configBus.objectWillChange
            .sink { [weak self] _ in
                if let newAppearance = configBus.load("InputBarAppearance", as: InputBarAppearance.self) {
                    self?.appearance = newAppearance
                }
            }
    }
}