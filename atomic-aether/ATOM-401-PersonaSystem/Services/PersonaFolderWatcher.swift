//
//  PersonaFolderWatcher.swift
//  atomic-aether
//
//  Watches persona folders for changes
//
//  ATOM 401: Personas - Dynamic folder watching service
//
//  Atomic LEGO: Monitors filesystem for persona changes
//  Enables hot-reload by detecting folder add/remove/modify
//

import Foundation
import SwiftUI
import Combine

@MainActor
class PersonaFolderWatcher: ObservableObject {
    // MARK: - Published Properties
    @Published private(set) var personas: [PersonaFolder] = []
    @Published private(set) var isWatching = false
    
    // MARK: - Dependencies
    private var configBus: ConfigBus?
    private var eventBus: EventBus?
    private var errorBus: ErrorBus?
    
    // MARK: - Properties
    private var configuration: PersonaFolderConfiguration = .default
    private var fileWatcher: DispatchSourceFileSystemObject?
    private let queue = DispatchQueue(label: "persona.folder.watcher", qos: .background)
    private var watchTimer: Timer?
    private var lastKnownPersonas: [String: PersonaFolder] = [:]
    
    // MARK: - Setup
    
    func setup(configBus: ConfigBus, eventBus: EventBus, errorBus: ErrorBus) {
        self.configBus = configBus
        self.eventBus = eventBus
        self.errorBus = errorBus
        
        // Load configuration
        if let config = configBus.load("PersonaFolders", as: PersonaFolderConfiguration.self) {
            configuration = config
        }
        
        // Start watching
        startWatching()
    }
    
    // MARK: - Watching
    
    func startWatching() {
        isWatching = true
        
        // Initial scan
        scanPersonaFolders()
        
        // Set up periodic scanning (simpler than FSEvents)
        watchTimer?.invalidate()
        watchTimer = Timer.scheduledTimer(withTimeInterval: configuration.watchInterval, repeats: true) { _ in
            Task { @MainActor in
                self.scanPersonaFolders()
            }
        }
    }
    
    func stopWatching() {
        isWatching = false
        watchTimer?.invalidate()
        watchTimer = nil
    }
    
    // MARK: - Scanning
    
    private func scanPersonaFolders() {
        let url = URL(fileURLWithPath: configuration.expandedPath)
        
        do {
            let contents = try FileManager.default.contentsOfDirectory(
                at: url,
                includingPropertiesForKeys: [.isDirectoryKey, .contentModificationDateKey],
                options: [.skipsHiddenFiles]
            )
            
            var currentPersonas: [String: PersonaFolder] = [:]
            var loadedPersonas: [PersonaFolder] = []
            
            for folderURL in contents {
                // Check if it's a directory
                var isDirectory: ObjCBool = false
                guard FileManager.default.fileExists(atPath: folderURL.path, isDirectory: &isDirectory),
                      isDirectory.boolValue else { continue }
                
                // Skip ignored folders
                let folderName = folderURL.lastPathComponent
                if configuration.shouldIgnore(folderName) { continue }
                
                // Try to load persona from folder
                if let persona = loadPersonaFromFolder(folderURL: folderURL) {
                    currentPersonas[persona.id] = persona
                    loadedPersonas.append(persona)
                }
            }
            
            // Sort by name
            loadedPersonas.sort { $0.displayName < $1.displayName }
            
            // Update published personas
            self.personas = loadedPersonas
            
            // Detect changes and publish events
            detectAndPublishChanges(current: currentPersonas)
            
            // Update last known state
            lastKnownPersonas = currentPersonas
            
        } catch {
            errorBus?.report(error, from: "PersonaFolderWatcher", severity: .warning)
            eventBus?.publish(PersonaFolderEvent.folderWatchError(error))
        }
    }
    
    private func loadPersonaFromFolder(folderURL: URL) -> PersonaFolder? {
        let folderName = folderURL.lastPathComponent
        
        // Look for markdown file with same name as folder
        let mdFile = folderURL
            .appendingPathComponent(folderName)
            .appendingPathExtension("md")
        
        // Check if file exists
        guard FileManager.default.fileExists(atPath: mdFile.path) else {
            // Try to find any .md file in the folder
            if let anyMdFile = findMarkdownFile(in: folderURL) {
                return loadPersonaFromFile(fileURL: anyMdFile, folderURL: folderURL)
            }
            return nil
        }
        
        return loadPersonaFromFile(fileURL: mdFile, folderURL: folderURL)
    }
    
    private func loadPersonaFromFile(fileURL: URL, folderURL: URL) -> PersonaFolder? {
        do {
            // Read file content
            let content = try String(contentsOf: fileURL, encoding: .utf8)
            
            // Parse frontmatter
            guard let parsed = FrontmatterParser.parse(fileContent: content) else {
                errorBus?.report(
                    AetherError.configurationInvalid(file: fileURL.lastPathComponent, reason: "Invalid frontmatter format"),
                    from: "PersonaFolderWatcher",
                    severity: .warning
                )
                return nil
            }
            
            // Get file modification date
            let attributes = try FileManager.default.attributesOfItem(atPath: fileURL.path)
            let lastModified = attributes[.modificationDate] as? Date ?? Date()
            
            // Create PersonaFolder
            let folderName = folderURL.lastPathComponent
            let isAnthropicValue = parsed.frontmatter["isAnthropic"] ?? "false"
            
            let personaFolder = PersonaFolder(
                id: folderName.lowercased(),
                folderPath: folderURL,
                displayName: parsed.frontmatter["name"] ?? folderName,
                avatar: parsed.frontmatter["avatar"] ?? configuration.defaultAvatar,
                color: Color(hex: parsed.frontmatter["color"]) ?? Color(hex: configuration.defaultColor)!,
                isAnthropic: isAnthropicValue.lowercased() == "true",
                personaType: parsed.frontmatter["personaType"],
                role: parsed.frontmatter["role"],
                lastModified: lastModified,
                content: parsed.content
            )
            
            return personaFolder
            
        } catch {
            errorBus?.report(error, from: "PersonaFolderWatcher", severity: .warning)
            return nil
        }
    }
    
    private func findMarkdownFile(in folderURL: URL) -> URL? {
        do {
            let contents = try FileManager.default.contentsOfDirectory(
                at: folderURL,
                includingPropertiesForKeys: nil,
                options: [.skipsHiddenFiles]
            )
            
            return contents.first { $0.pathExtension == "md" }
        } catch {
            return nil
        }
    }
    
    // MARK: - Change Detection
    
    private func detectAndPublishChanges(current: [String: PersonaFolder]) {
        // Check for added personas
        for (id, persona) in current {
            if lastKnownPersonas[id] == nil {
                eventBus?.publish(PersonaFolderEvent.personaAdded(persona))
            }
        }
        
        // Check for removed personas
        for (id, _) in lastKnownPersonas {
            if current[id] == nil {
                eventBus?.publish(PersonaFolderEvent.personaRemoved(id))
            }
        }
        
        // Check for updated personas
        for (id, persona) in current {
            if let oldPersona = lastKnownPersonas[id],
               oldPersona.lastModified != persona.lastModified {
                eventBus?.publish(PersonaFolderEvent.personaUpdated(persona))
            }
        }
        
        // Always publish full list on first load or if there are any changes
        if lastKnownPersonas.isEmpty || current != lastKnownPersonas {
            eventBus?.publish(PersonaFolderEvent.personasLoaded(Array(current.values)))
        }
    }
    
    // MARK: - Cleanup
    
    deinit {
        // Timer will be invalidated automatically when the object is deallocated
        watchTimer?.invalidate()
    }
}