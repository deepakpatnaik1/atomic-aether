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
            if case .commandDetected(let command) = event, command.trigger == "/journal" {
                self?.handleJournalCommand()
            }
        }
        .store(in: &cancellables)
    }
    
    private func handleJournalCommand() {
        // Publish triggered event
        eventBus.publish(JournalCommandEvent.triggered())
        
        // Build the prefix text if enabled
        var prefixText: String? = nil
        if configuration.autoInsertPrefix {
            prefixText = buildPrefixText()
        }
        
        // Update input state
        stateBus?.set(StateKey<Int>("inputBar.expandedLines"), value: configuration.expandToLines)
        
        // Insert prefix text if configured
        if let prefix = prefixText {
            // Small delay to ensure input is ready
            Task { @MainActor in
                try? await Task.sleep(nanoseconds: 100_000_000) // 0.1 second
                eventBus.publish(InputEvent.insertText(text: prefix, source: "JournalCommand"))
            }
        }
        
        // Publish expanded event
        eventBus.publish(JournalCommandEvent.expanded(
            lines: configuration.expandToLines,
            prefix: prefixText
        ))
    }
    
    private func buildPrefixText() -> String {
        var prefix = configuration.prefixTemplate
        
        // Add date if configured
        if prefix.contains("{date}") {
            let formatter = DateFormatter()
            formatter.dateFormat = configuration.dateFormat
            let dateString = formatter.string(from: Date())
            prefix = prefix.replacingOccurrences(of: "{date}", with: dateString)
        }
        
        // Add timestamp if configured
        if configuration.enableTimestamp {
            let formatter = DateFormatter()
            formatter.dateFormat = configuration.timestampFormat
            let timeString = formatter.string(from: Date())
            prefix += " - \(timeString)"
        }
        
        // Add newlines based on cursor position
        switch configuration.insertCursorPosition {
        case .afterPrefix:
            prefix += " "
        case .newLine:
            prefix += "\n\n"
        case .end:
            prefix += "\n\n\n"
        }
        
        return prefix
    }
    
    // Public method to manually trigger journal mode
    func triggerJournalMode() {
        handleJournalCommand()
    }
}