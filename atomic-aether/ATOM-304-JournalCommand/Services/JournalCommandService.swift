//
//  JournalCommandService.swift
//  atomic-aether
//
//  Service to handle /journal command execution
//
//  ATOM 304: JournalCommand - Core service
//

import Foundation
import SwiftUI
import Combine

@MainActor
class JournalCommandService: ObservableObject {
    private var configuration: JournalCommandConfiguration = .default
    private let configBus: ConfigBus
    private let eventBus: EventBus
    private let stateBus: StateBus?
    private var cancellables = Set<AnyCancellable>()
    
    init(configBus: ConfigBus, eventBus: EventBus, stateBus: StateBus? = nil) {
        self.configBus = configBus
        self.eventBus = eventBus
        self.stateBus = stateBus
        
        loadConfiguration()
        subscribeToEvents()
    }
    
    private func loadConfiguration() {
        if let config = configBus.load("JournalCommand", as: JournalCommandConfiguration.self) {
            self.configuration = config
        }
    }
    
    private func subscribeToEvents() {
        // Listen for slash command detection
        eventBus.subscribe(to: SlashCommandEvent.self) { [weak self] event in
            guard let self = self else { return }
            
            if case .commandDetected(let command) = event, 
               command.trigger == self.configuration.trigger {
                self.handleJournalCommand()
            }
        }
        .store(in: &cancellables)
    }
    
    private func handleJournalCommand() {
        // Publish triggered event
        eventBus.publish(JournalCommandEvent.triggered())
        
        // Update input state to expand
        stateBus?.set(StateKey<Int>("inputBar.expandedLines"), value: configuration.expandToLines)
        
        // Publish expanded event
        eventBus.publish(JournalCommandEvent.expanded(lines: configuration.expandToLines))
    }
}