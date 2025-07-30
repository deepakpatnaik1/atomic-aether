//
//  SlashCommandDetector.swift
//  atomic-aether
//
//  Service to detect and manage slash commands
//
//  ATOM 4: /journal Slash Command - Command detection service
//  ATOM 6: ConfigBus - Loads commands from configuration
//  ATOM 5: EventBus - Publishes command events
//
//  Atomic LEGO: Single responsibility - detect commands
//  Tracks state for height restoration
//

import SwiftUI
import Combine

@MainActor
class SlashCommandDetector: ObservableObject {
    @Published var activeCommand: SlashCommand?
    @Published var isExpanded = false
    
    private var commands: [SlashCommand] = []
    private var configBus: ConfigBus?
    private var eventBus: EventBus?
    private var cancellable: AnyCancellable?
    
    init() {
        // Commands will be loaded via setupWithBuses
    }
    
    /// Setup with ConfigBus and EventBus
    func setupWithBuses(_ configBus: ConfigBus, _ eventBus: EventBus) {
        self.configBus = configBus
        self.eventBus = eventBus
        
        // Load commands from ConfigBus
        if let config = configBus.load("SlashCommands", as: SlashCommandConfiguration.self) {
            commands = config.commands
            print("✅ Loaded \(commands.count) slash commands from ConfigBus")
        } else {
            print("❌ FATAL: SlashCommands.json missing from bundle")
            commands = []
        }
        
        // Watch for config changes
        cancellable = configBus.objectWillChange
            .sink { [weak self] _ in
                if let config = configBus.load("SlashCommands", as: SlashCommandConfiguration.self) {
                    self?.commands = config.commands
                    print("🔄 Reloaded \(config.commands.count) slash commands")
                }
            }
    }
    
    func detectCommand(in text: String) -> SlashCommand? {
        // Check if text starts with any command trigger
        for command in commands {
            if text.lowercased() == command.trigger.lowercased() {
                return command
            }
        }
        return nil
    }
    
    func handleTextChange(_ text: String) -> Bool {
        let detectedCommand = detectCommand(in: text)
        var shouldClearText = false
        
        // Publish event if command detected
        if let command = detectedCommand {
            eventBus?.publish(InputEvent.slashCommandEntered(
                command: command.trigger,
                source: "SlashCommandDetector"
            ))
        }
        
        // Dispatch to avoid "Publishing changes from within view updates" warning
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            if let command = detectedCommand, command.expandToLines != nil {
                // Activate expansion
                self.activeCommand = command
                self.isExpanded = true
            } else if self.activeCommand != nil && !text.starts(with: self.activeCommand!.trigger) {
                // Text changed, no longer just the command
                // Keep expanded but ready for manual clear
                self.isExpanded = true
            }
        }
        
        // Return true if we should clear the text
        if let command = detectedCommand, command.expandToLines != nil {
            shouldClearText = true
        }
        
        return shouldClearText
    }
    
    func shouldAllowCollapse(text: String) -> Bool {
        // Allow collapse if we have an active command and text is empty (command was cleared)
        guard activeCommand != nil else { 
            print("❌ No active command")
            return false 
        }
        let shouldCollapse = text.isEmpty && isExpanded
        print("🔍 Checking collapse: text='\(text)', isExpanded=\(isExpanded), allow=\(shouldCollapse)")
        return shouldCollapse
    }
    
    func collapse() {
        print("✅ Collapsing input bar")
        // Dispatch to avoid "Publishing changes from within view updates" warning
        DispatchQueue.main.async { [weak self] in
            self?.activeCommand = nil
            self?.isExpanded = false
        }
    }
}