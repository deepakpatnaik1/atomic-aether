//
//  JournalService.swift
//  atomic-aether
//
//  Manages journal entries and file persistence
//
//  ATOM 24: Journal Service - Core service
//
//  Atomic LEGO: Maintains living memory of conversations
//  Subscribes to machine trim events and persists to disk
//

import Foundation
import Combine

@MainActor
class JournalService: ObservableObject {
    // MARK: - Published Properties
    @Published private(set) var entries: [JournalEntry] = []
    @Published private(set) var isLoading = false
    @Published private(set) var lastError: Error?
    
    // MARK: - Dependencies
    private var configuration: JournalConfiguration = .default
    private var configBus: ConfigBus?
    private var eventBus: EventBus?
    private var errorBus: ErrorBus?
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Setup
    func setup(configBus: ConfigBus, eventBus: EventBus, errorBus: ErrorBus) {
        self.configBus = configBus
        self.eventBus = eventBus
        self.errorBus = errorBus
        
        loadConfiguration()
        loadExistingJournal()
        subscribeToResponseParserEvents()
    }
    
    private func loadConfiguration() {
        if let config = configBus?.load("Journal", as: JournalConfiguration.self) {
            self.configuration = config
        }
    }
    
    // MARK: - Event Subscription
    private func subscribeToResponseParserEvents() {
        eventBus?.subscribe(to: ResponseParserEvent.self) { [weak self] event in
            Task { @MainActor in
                switch event {
                case .machineTrimComplete(let content):
                    await self?.processMachineTrim(content)
                case .fullyInferableResponse:
                    // Nothing to store - entire response was inferable
                    break
                default:
                    break
                }
            }
        }
        .store(in: &cancellables)
    }
    
    // MARK: - Machine Trim Processing
    private func processMachineTrim(_ content: String) async {
        // Skip if only contains inferable marker
        guard content != "[INFERABLE - NOT STORED]" else { return }
        
        // Parse the machine trim content
        let entry = parseMachineTrim(content)
        
        // Add to memory
        entries.append(entry)
        
        // Maintain memory limit
        if entries.count > configuration.maxEntriesInMemory {
            let overflow = entries.count - configuration.maxEntriesInMemory
            entries.removeFirst(overflow)
        }
        
        // Append to file
        do {
            try await appendToJournalFile(entry)
            eventBus?.publish(JournalEvent.entryAdded(entry))
        } catch {
            lastError = error
            errorBus?.publish(error, severity: .medium)
            eventBus?.publish(JournalEvent.journalError(error))
        }
    }
    
    // MARK: - Parsing
    private func parseMachineTrim(_ content: String) -> JournalEntry {
        let timestamp = Date()
        var sentiment: String? = nil
        var lines = content.split(separator: "\n").map(String.init)
        
        // Extract sentiment if present
        if let firstLine = lines.first, firstLine.starts(with: "sentiment:") {
            sentiment = String(firstLine.dropFirst("sentiment:".count)).trimmingCharacters(in: .whitespaces)
            lines.removeFirst()
        }
        
        // Join remaining lines as content
        let trimmedContent = lines.joined(separator: " ").trimmingCharacters(in: .whitespaces)
        
        // For now, we'll parse speaker from content later when format is finalized
        return JournalEntry(
            timestamp: timestamp,
            localTimeString: formatLocalTime(timestamp),
            speaker: "Conversation",  // Will be parsed from content
            content: trimmedContent,
            sentiment: sentiment,
            isInferable: false
        )
    }
    
    private func formatLocalTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = configuration.dateFormat
        formatter.timeZone = .current
        
        return formatter.string(from: date) + " " +
               (TimeZone.current.abbreviation() ?? TimeZone.current.identifier)
    }
    
    // MARK: - File Operations
    private func loadExistingJournal() {
        isLoading = true
        defer { isLoading = false }
        
        guard let url = configuration.journalURL else {
            errorBus?.publish(
                AetherError.configuration("Invalid journal path"),
                severity: .low
            )
            return
        }
        
        do {
            // Check if file exists
            guard FileManager.default.fileExists(atPath: url.path) else {
                // No existing journal - that's OK
                return
            }
            
            // Read file content
            let content = try String(contentsOf: url, encoding: .utf8)
            
            // Parse entries (simplified for now - will need proper parsing)
            // For now, we'll just count delimiters to report loaded entries
            let entryCount = content.components(separatedBy: configuration.appendDelimiter).count - 1
            
            eventBus?.publish(JournalEvent.journalLoaded(entryCount: max(0, entryCount)))
            
            // TODO: Implement actual parsing when format is finalized
            
        } catch {
            lastError = error
            errorBus?.publish(error, severity: .medium)
        }
    }
    
    private func appendToJournalFile(_ entry: JournalEntry) async throws {
        guard let url = configuration.journalURL else {
            throw AetherError.configuration("Invalid journal path")
        }
        
        // Create directory if needed
        if configuration.createPathIfMissing {
            let directory = url.deletingLastPathComponent()
            try FileManager.default.createDirectory(
                at: directory,
                withIntermediateDirectories: true
            )
        }
        
        // Format entry for file
        var entryText = "\(entry.localTimeString): "
        if let sentiment = entry.sentiment {
            entryText += "sentiment: \(sentiment) "
        }
        entryText += entry.content
        
        // Check if file exists
        let fileExists = FileManager.default.fileExists(atPath: url.path)
        
        // Prepare content to append
        let contentToAppend = fileExists 
            ? configuration.appendDelimiter + entryText
            : entryText
        
        // Append to file
        if let data = contentToAppend.data(using: .utf8) {
            if fileExists {
                // Append to existing file
                let fileHandle = try FileHandle(forWritingTo: url)
                defer { try? fileHandle.close() }
                fileHandle.seekToEndOfFile()
                fileHandle.write(data)
            } else {
                // Create new file
                try data.write(to: url)
            }
        }
    }
    
    // MARK: - Public Interface
    
    /// Get formatted journal content for system prompt
    func getJournalForPrompt() -> String {
        entries.map { entry in
            var result = ""
            if let sentiment = entry.sentiment {
                result += "sentiment: \(sentiment) "
            }
            result += entry.content
            return result
        }.joined(separator: "\n")
    }
    
    /// Get journal content with timestamps for debugging
    func getJournalWithTimestamps() -> String {
        entries.map { entry in
            "\(entry.localTimeString): \(entry.content)"
        }.joined(separator: "\n")
    }
}