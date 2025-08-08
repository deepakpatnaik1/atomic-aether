//
//  BossProfileService.swift
//  atomic-aether
//
//  Reads all files from boss folder for system prompt
//
//  ATOM 26: Boss Profile Service - Core service
//
//  Atomic LEGO: Simple folder reader
//  Everything in boss folder becomes context
//

import Foundation
import SwiftUI
import Combine

@MainActor
class BossProfileService: ObservableObject {
    // MARK: - Published Properties
    @Published private(set) var isLoaded = false
    @Published private(set) var fileCount = 0
    @Published private(set) var lastError: Error?
    @Published private(set) var bossColor: Color = Color.gray
    @Published private(set) var bossDisplayName: String = "Boss"
    
    // MARK: - Private Properties
    private var configuration: BossProfileConfiguration = .default
    private var cachedProfile: String = ""
    private var lastLoadTime: Date?
    
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
        loadProfile()
    }
    
    private func loadConfiguration() {
        if let config = configBus?.load("BossProfile", as: BossProfileConfiguration.self) {
            self.configuration = config
        }
    }
    
    // MARK: - Profile Loading
    private func loadProfile() {
        guard let profileURL = configuration.profileURL else {
            let error = NSError(
                domain: "BossProfileService",
                code: 1,
                userInfo: [NSLocalizedDescriptionKey: "Invalid profile path"]
            )
            handleError(error)
            return
        }
        
        do {
            // Check if directory exists
            var isDirectory: ObjCBool = false
            guard FileManager.default.fileExists(atPath: profileURL.path, isDirectory: &isDirectory),
                  isDirectory.boolValue else {
                // Create directory if it doesn't exist
                try FileManager.default.createDirectory(
                    at: profileURL,
                    withIntermediateDirectories: true
                )
                // Empty profile for new directory
                cachedProfile = ""
                fileCount = 0
                isLoaded = true
                eventBus?.publish(BossProfileEvent.profileLoaded(fileCount: 0))
                return
            }
            
            // Get all files in directory
            let files = try FileManager.default.contentsOfDirectory(
                at: profileURL,
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
                    // Special handling for Boss.md
                    if fileURL.lastPathComponent == "Boss.md" {
                        // Parse frontmatter for Boss metadata
                        if let parsed = FrontmatterParser.parse(fileContent: content) {
                            if let name = parsed.frontmatter["name"] {
                                bossDisplayName = name
                            }
                            if let colorHex = parsed.frontmatter["color"], 
                               let color = Color(hex: colorHex) {
                                bossColor = color
                            }
                        }
                    }
                    
                    let header = configuration.fileSeparator
                        .replacingOccurrences(of: "{filename}", with: fileURL.lastPathComponent)
                    sections.append(header + content)
                    loadedCount += 1
                }
            }
            
            // Update state
            cachedProfile = sections.joined()
            fileCount = loadedCount
            lastLoadTime = Date()
            isLoaded = true
            
            eventBus?.publish(BossProfileEvent.profileLoaded(fileCount: loadedCount))
            
        } catch {
            handleError(error)
        }
    }
    
    // MARK: - Public Interface
    
    /// Get the complete profile content for system prompt
    func getProfileForPrompt() -> String {
        return cachedProfile
    }
    
    /// Reload profile from disk
    func refreshProfile() {
        loadProfile()
    }
    
    /// Check if profile needs refresh (for future use)
    func needsRefresh() -> Bool {
        guard let lastLoad = lastLoadTime else { return true }
        return Date().timeIntervalSince(lastLoad) > 300 // 5 minutes
    }
    
    // MARK: - Error Handling
    
    private func handleError(_ error: Error) {
        lastError = error
        errorBus?.report(error, from: "BossProfileService", severity: .warning)
        eventBus?.publish(BossProfileEvent.profileError(error))
    }
}