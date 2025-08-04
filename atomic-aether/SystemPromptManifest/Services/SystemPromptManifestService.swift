//
//  SystemPromptManifestService.swift
//  atomic-aether
//
//  Saves system prompts to files for debugging and transparency
//
//  ATOM 29: System Prompt Manifest - Core service
//
//  Atomic LEGO: Observes and saves system prompts
//  Pure observer - no modification of behavior
//

import Foundation
import Combine

@MainActor
class SystemPromptManifestService: ObservableObject {
    // MARK: - Published Properties
    @Published private(set) var lastSavedPath: String?
    @Published private(set) var lastError: Error?
    
    // MARK: - Private Properties
    private var configuration: SystemPromptManifestConfiguration = .default
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Dependencies
    private var configBus: ConfigBus?
    private var eventBus: EventBus?
    private var errorBus: ErrorBus?
    private var systemPromptBuilder: SystemPromptBuilderService?
    
    // MARK: - Setup
    func setup(
        configBus: ConfigBus,
        eventBus: EventBus,
        errorBus: ErrorBus,
        systemPromptBuilder: SystemPromptBuilderService
    ) {
        self.configBus = configBus
        self.eventBus = eventBus
        self.errorBus = errorBus
        self.systemPromptBuilder = systemPromptBuilder
        
        loadConfiguration()
        subscribeToPromptEvents()
    }
    
    private func loadConfiguration() {
        if let config = configBus?.load("SystemPromptManifest", as: SystemPromptManifestConfiguration.self) {
            self.configuration = config
        }
    }
    
    // MARK: - Event Subscription
    private func subscribeToPromptEvents() {
        // Subscribe to prompt built events
        eventBus?.subscribe(to: SystemPromptEvent.self) { [weak self] event in
            Task { @MainActor in
                switch event {
                case .promptBuilt(let personaId, let length):
                    await self?.handlePromptBuilt(personaId: personaId, length: length)
                default:
                    break
                }
            }
        }
        .store(in: &cancellables)
    }
    
    // MARK: - Prompt Handling
    private func handlePromptBuilt(personaId: String, length: Int) async {
        // Get the actual prompt from the builder
        guard let prompt = systemPromptBuilder?.buildSystemPrompt(personaId: personaId) else {
            return
        }
        
        await saveManifest(prompt: prompt, personaId: personaId, length: length)
    }
    
    // MARK: - File Operations
    private func saveManifest(prompt: String, personaId: String, length: Int) async {
        do {
            // Determine save location
            let saveURL: URL
            if configuration.saveEveryPrompt {
                // Save with timestamp
                guard let baseURL = configuration.manifestURL?.deletingLastPathComponent() else {
                    throw NSError(
                        domain: "SystemPromptManifest",
                        code: 1,
                        userInfo: [NSLocalizedDescriptionKey: "Invalid manifest path"]
                    )
                }
                let filename = configuration.timestampedFilename(for: Date())
                saveURL = baseURL.appendingPathComponent(filename)
            } else {
                // Overwrite single file
                guard let url = configuration.manifestURL else {
                    throw NSError(
                        domain: "SystemPromptManifest",
                        code: 1,
                        userInfo: [NSLocalizedDescriptionKey: "Invalid manifest path"]
                    )
                }
                saveURL = url
            }
            
            // Create directory if needed
            if configuration.createPathIfMissing {
                let directory = saveURL.deletingLastPathComponent()
                try FileManager.default.createDirectory(
                    at: directory,
                    withIntermediateDirectories: true
                )
            }
            
            // Build content
            var content = ""
            
            // Add metadata header if configured
            if configuration.includeMetadata {
                let formatter = DateFormatter()
                formatter.dateFormat = configuration.timestampFormat
                formatter.timeZone = .current
                
                content += "# System Prompt Manifest\n\n"
                content += "Generated: \(formatter.string(from: Date())) "
                content += "\(TimeZone.current.abbreviation() ?? TimeZone.current.identifier)\n"
                content += "Persona: \(personaId)\n"
                content += "Length: \(length.formatted()) characters\n"
                content += "\n---\n\n"
            }
            
            // Add the actual prompt
            content += prompt
            
            // Write to file
            try content.write(to: saveURL, atomically: true, encoding: .utf8)
            lastSavedPath = saveURL.path
            
        } catch {
            lastError = error
            errorBus?.report(
                error,
                from: "SystemPromptManifest",
                severity: .warning,
                additionalInfo: ["personaId": personaId]
            )
        }
    }
    
    // MARK: - Public Methods
    
    /// Manually save current system prompt for a persona
    func saveCurrentPrompt(for personaId: String) async {
        guard let prompt = systemPromptBuilder?.buildSystemPrompt(personaId: personaId) else {
            return
        }
        
        await saveManifest(
            prompt: prompt,
            personaId: personaId,
            length: prompt.count
        )
    }
}