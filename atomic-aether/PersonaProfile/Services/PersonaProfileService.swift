//
//  PersonaProfileService.swift
//  atomic-aether
//
//  Reads persona-specific files from persona folders
//
//  ATOM 27: Persona Profile Service - Core service
//
//  Atomic LEGO: Per-persona folder reader
//  Each persona can have additional context files
//

import Foundation
import Combine

@MainActor
class PersonaProfileService: ObservableObject {
    // MARK: - Published Properties
    @Published private(set) var loadedProfiles: Set<String> = []
    @Published private(set) var lastError: Error?
    
    // MARK: - Private Properties
    private var configuration: PersonaProfileConfiguration = .default
    private var profileCache: [String: String] = [:]
    private var lastLoadTime: [String: Date] = [:]
    
    // MARK: - Dependencies
    private var configBus: ConfigBus?
    private var eventBus: EventBus?
    private var errorBus: ErrorBus?
    
    // MARK: - Setup
    func setup(configBus: ConfigBus, eventBus: EventBus, errorBus: ErrorBus) {
        self.configBus = configBus
        self.eventBus = eventBus
        self.errorBus = errorBus
        
        loadConfiguration()
        createPersonasDirectoryIfNeeded()
    }
    
    private func loadConfiguration() {
        if let config = configBus?.load("PersonaProfile", as: PersonaProfileConfiguration.self) {
            self.configuration = config
        }
    }
    
    private func createPersonasDirectoryIfNeeded() {
        guard let personasURL = configuration.personasURL else { return }
        
        // Create personas directory if it doesn't exist
        if !FileManager.default.fileExists(atPath: personasURL.path) {
            try? FileManager.default.createDirectory(
                at: personasURL,
                withIntermediateDirectories: true
            )
        }
    }
    
    // MARK: - Profile Loading
    
    /// Get profile content for a specific persona
    func getProfileForPrompt(personaId: String) -> String {
        // Return cached if available
        if let cached = profileCache[personaId] {
            return cached
        }
        
        // Load and cache
        loadProfileForPersona(personaId)
        return profileCache[personaId] ?? ""
    }
    
    private func loadProfileForPersona(_ personaId: String) {
        guard let personaURL = configuration.urlForPersona(personaId) else {
            let error = NSError(
                domain: "PersonaProfileService",
                code: 1,
                userInfo: [NSLocalizedDescriptionKey: "Invalid persona path for \(personaId)"]
            )
            handleError(error, personaId: personaId)
            return
        }
        
        do {
            // Check if directory exists
            var isDirectory: ObjCBool = false
            guard FileManager.default.fileExists(atPath: personaURL.path, isDirectory: &isDirectory),
                  isDirectory.boolValue else {
                // No folder for this persona - that's OK
                profileCache[personaId] = ""
                loadedProfiles.insert(personaId)
                eventBus?.publish(PersonaProfileEvent.profileLoaded(personaId: personaId, fileCount: 0))
                return
            }
            
            // Get all files in persona directory
            let files = try FileManager.default.contentsOfDirectory(
                at: personaURL,
                includingPropertiesForKeys: [.fileSizeKey],
                options: [.skipsHiddenFiles]
            )
            
            // Filter and sort files
            let validFiles = files
                .filter { configuration.shouldIncludeFile($0) }
                .sorted { $0.lastPathComponent < $1.lastPathComponent }
            
            // Read and concatenate files
            var sections: [String] = []
            var loadedCount = 0
            
            for fileURL in validFiles {
                // Check file size
                if let fileSize = try? fileURL.resourceValues(forKeys: [.fileSizeKey]).fileSize,
                   fileSize > configuration.maxFileSizeKB * 1024 {
                    continue // Skip large files
                }
                
                // Read file content
                if let content = try? String(contentsOf: fileURL, encoding: .utf8) {
                    let header = configuration.fileSeparator
                        .replacingOccurrences(of: "{filename}", with: fileURL.lastPathComponent)
                    sections.append(header + content)
                    loadedCount += 1
                }
            }
            
            // Update cache
            profileCache[personaId] = sections.joined()
            lastLoadTime[personaId] = Date()
            loadedProfiles.insert(personaId)
            
            eventBus?.publish(PersonaProfileEvent.profileLoaded(
                personaId: personaId,
                fileCount: loadedCount
            ))
            
        } catch {
            handleError(error, personaId: personaId)
        }
    }
    
    // MARK: - Public Methods
    
    /// Clear cache for a specific persona
    func clearCache(for personaId: String) {
        profileCache.removeValue(forKey: personaId)
        lastLoadTime.removeValue(forKey: personaId)
        loadedProfiles.remove(personaId)
    }
    
    /// Clear all cached profiles
    func clearAllCaches() {
        profileCache.removeAll()
        lastLoadTime.removeAll()
        loadedProfiles.removeAll()
    }
    
    // MARK: - Error Handling
    
    private func handleError(_ error: Error, personaId: String) {
        lastError = error
        errorBus?.report(
            error,
            from: "PersonaProfileService",
            severity: .warning,
            additionalInfo: ["personaId": personaId]
        )
        eventBus?.publish(PersonaProfileEvent.profileError(
            personaId: personaId,
            error: error
        ))
    }
}