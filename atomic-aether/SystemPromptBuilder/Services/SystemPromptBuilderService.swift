//
//  SystemPromptBuilderService.swift
//  atomic-aether
//
//  Assembles complete system prompts from multiple sources
//
//  ATOM 28: System Prompt Builder - Core service
//
//  Atomic LEGO: Combines all context sources
//  Simple string concatenation with configured ordering
//

import Foundation
import Combine

@MainActor
class SystemPromptBuilderService: ObservableObject {
    // MARK: - Published Properties
    @Published private(set) var lastBuiltPromptLength: Int = 0
    
    // MARK: - Private Properties
    private var configuration: SystemPromptConfiguration = .default
    
    // MARK: - Dependencies
    private var configBus: ConfigBus?
    private var eventBus: EventBus?
    private var personaStateService: PersonaStateService?
    private var bossProfileService: BossProfileService?
    private var personaProfileService: PersonaProfileService?
    private var journalService: JournalService?
    
    // MARK: - Setup
    func setup(
        configBus: ConfigBus,
        eventBus: EventBus,
        personaStateService: PersonaStateService,
        bossProfileService: BossProfileService,
        personaProfileService: PersonaProfileService,
        journalService: JournalService
    ) {
        self.configBus = configBus
        self.eventBus = eventBus
        self.personaStateService = personaStateService
        self.bossProfileService = bossProfileService
        self.personaProfileService = personaProfileService
        self.journalService = journalService
        
        loadConfiguration()
    }
    
    private func loadConfiguration() {
        if let config = configBus?.load("SystemPromptBuilder", as: SystemPromptConfiguration.self) {
            self.configuration = config
        }
    }
    
    // MARK: - Prompt Building
    
    /// Build complete system prompt for a persona
    func buildSystemPrompt(personaId: String) -> String {
        var sections: [String] = []
        
        for sectionName in configuration.sectionOrder {
            switch sectionName {
            case "persona":
                if let prompt = getPersonaBasePrompt(personaId) {
                    sections.append(formatSection(sectionName, content: prompt))
                } else {
                    eventBus?.publish(SystemPromptEvent.sectionOmitted(
                        section: sectionName,
                        reason: "No persona definition found"
                    ))
                }
                
            case "bossProfile":
                if let profile = bossProfileService?.getProfileForPrompt(),
                   !profile.isEmpty {
                    sections.append(formatSection(sectionName, content: profile))
                } else {
                    eventBus?.publish(SystemPromptEvent.sectionOmitted(
                        section: sectionName,
                        reason: "Boss profile empty"
                    ))
                }
                
            case "personaProfile":
                if let profile = personaProfileService?.getProfileForPrompt(personaId: personaId),
                   !profile.isEmpty {
                    sections.append(formatSection(sectionName, content: profile))
                } else {
                    eventBus?.publish(SystemPromptEvent.sectionOmitted(
                        section: sectionName,
                        reason: "Persona profile empty"
                    ))
                }
                
            case "journal":
                if let journal = journalService?.getJournalForPrompt() {
                    let truncated = truncateIfNeeded(journal, maxChars: configuration.maxJournalCharacters)
                    if !truncated.isEmpty {
                        sections.append(formatSection(sectionName, content: truncated))
                    } else {
                        eventBus?.publish(SystemPromptEvent.sectionOmitted(
                            section: sectionName,
                            reason: "Journal empty"
                        ))
                    }
                }
                
            default:
                // Unknown section - skip
                break
            }
        }
        
        let prompt = sections.joined(separator: configuration.sectionSeparator)
        lastBuiltPromptLength = prompt.count
        
        eventBus?.publish(SystemPromptEvent.promptBuilt(
            personaId: personaId,
            length: prompt.count
        ))
        
        return prompt
    }
    
    // MARK: - Private Helpers
    
    private func getPersonaBasePrompt(_ personaId: String) -> String? {
        // Get the base system prompt from PersonaStateService
        // No need to switch - just get the persona's system prompt directly
        guard let persona = personaStateService?.configuration.persona(for: personaId) else {
            return nil
        }
        return persona.systemPrompt
    }
    
    private func formatSection(_ name: String, content: String) -> String {
        if let header = configuration.header(for: name) {
            return "\(header)\n\n\(content)"
        } else {
            return content
        }
    }
    
    private func truncateIfNeeded(_ text: String, maxChars: Int) -> String {
        guard text.count > maxChars else { return text }
        
        let endIndex = text.index(text.startIndex, offsetBy: maxChars)
        return String(text[..<endIndex]) + "\n[... truncated ...]"
    }
}