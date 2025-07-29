//
//  SlashCommandDetector.swift
//  atomic-aether
//
//  Service to detect and manage slash commands
//
//  Atomic LEGO: Single responsibility - detect commands
//  Tracks state for height restoration
//

import SwiftUI

class SlashCommandDetector: ObservableObject {
    @Published var activeCommand: SlashCommand?
    @Published var isExpanded = false
    
    private var commands: [SlashCommand] = []
    
    init() {
        loadCommands()
    }
    
    private func loadCommands() {
        // Look for JSON file in bundle
        guard let url = Bundle.main.url(forResource: "SlashCommands", withExtension: "json") else {
            print("⚠️ SlashCommands.json not found - using fallback")
            commands = [
                SlashCommand(
                    trigger: "/journal",
                    expandToLines: 34,
                    description: "Expand input for journal entry"
                )
            ]
            return
        }
        
        do {
            let data = try Data(contentsOf: url)
            let config = try JSONDecoder().decode(SlashCommandConfiguration.self, from: data)
            commands = config.commands
            print("✅ Loaded \(commands.count) slash commands")
        } catch {
            print("❌ Failed to load SlashCommands.json: \(error)")
            // Use fallback
            commands = [
                SlashCommand(
                    trigger: "/journal",
                    expandToLines: 34,
                    description: "Expand input for journal entry"
                )
            ]
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