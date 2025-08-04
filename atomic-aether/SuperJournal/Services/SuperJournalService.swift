//
//  SuperJournalService.swift
//  atomic-aether
//
//  Manages complete conversation persistence to disk
//
//  ATOM 25: SuperJournal Service - Core service
//
//  Atomic LEGO: Saves scrollback exactly as displayed
//  Real-time append with file rotation
//

import Foundation
import Combine

@MainActor
class SuperJournalService: ObservableObject {
    // MARK: - Published Properties
    @Published private(set) var currentFilePath: String?
    @Published private(set) var messageCount: Int = 0
    @Published private(set) var lastError: Error?
    
    // MARK: - Private Properties
    private var configuration: SuperJournalConfiguration = .default
    private var currentFileHandle: FileHandle?
    private var currentFileURL: URL?
    private var messagesInCurrentFile: Int = 0
    
    // MARK: - Dependencies
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
        createNewFile()
        subscribeToMessageEvents()
    }
    
    private func loadConfiguration() {
        if let config = configBus?.load("SuperJournal", as: SuperJournalConfiguration.self) {
            self.configuration = config
        }
    }
    
    // MARK: - Event Subscription
    private func subscribeToMessageEvents() {
        // Subscribe to message added events
        eventBus?.subscribe(to: MessageAddedEvent.self) { [weak self] event in
            Task { @MainActor in
                await self?.handleNewMessage(event.message)
            }
        }
        .store(in: &cancellables)
        
        // Subscribe to message updated events (for streaming)
        eventBus?.subscribe(to: MessageUpdatedEvent.self) { [weak self] event in
            Task { @MainActor in
                // For streaming messages, we could update the last entry
                // For now, we'll handle complete messages only
                if !event.message.isStreaming {
                    await self?.handleNewMessage(event.message)
                }
            }
        }
        .store(in: &cancellables)
    }
    
    // MARK: - Message Handling
    private func handleNewMessage(_ message: Message) async {
        // Skip system messages if configured
        // (Message model doesn't have role, all messages from MessageStore are user/assistant)
        // System messages are handled differently in this architecture
        
        // Check if rotation needed
        if messagesInCurrentFile >= configuration.maxMessagesPerFile {
            await rotateFile()
        }
        
        // Format entry
        let entry = SuperJournalEntry(
            timestamp: message.timestamp,
            speaker: formatSpeaker(for: message),
            content: message.content,
            isStreaming: message.isStreaming
        )
        
        // Write to file
        do {
            try await writeEntry(entry)
            messagesInCurrentFile += 1
            messageCount += 1
            
            eventBus?.publish(SuperJournalEvent.entryWritten(count: messageCount))
        } catch {
            lastError = error
            errorBus?.report(error, from: "SuperJournalService", severity: .error)
            eventBus?.publish(SuperJournalEvent.superJournalError(error))
        }
    }
    
    private func formatSpeaker(for message: Message) -> String {
        // Message.speaker is the persona ID or "user"
        // Format it for display
        if message.speaker == "user" {
            return "Boss"
        } else {
            // Use the speaker ID as the display name
            // In a full implementation, we'd look up the persona display name
            return message.speaker
        }
    }
    
    // MARK: - File Operations
    private func createNewFile() {
        do {
            // Ensure directory exists
            guard let saveURL = configuration.saveURL else {
                throw NSError(
                    domain: "SuperJournalService",
                    code: 1,
                    userInfo: [NSLocalizedDescriptionKey: "Invalid save path"]
                )
            }
            
            if configuration.createPathIfMissing {
                try FileManager.default.createDirectory(
                    at: saveURL,
                    withIntermediateDirectories: true
                )
            }
            
            // Generate filename
            let filename = configuration.generateFilename()
            let fileURL = saveURL.appendingPathComponent(filename)
            
            // Create file
            FileManager.default.createFile(atPath: fileURL.path, contents: nil)
            
            // Open file handle
            currentFileHandle = try FileHandle(forWritingTo: fileURL)
            currentFileURL = fileURL
            currentFilePath = fileURL.path
            messagesInCurrentFile = 0
            
            // Write header
            let header = "# Conversation Log\n\nStarted: \(formatLocalTime(Date()))\n\n---\n\n"
            if let data = header.data(using: .utf8) {
                currentFileHandle?.write(data)
            }
            
            eventBus?.publish(SuperJournalEvent.fileCreated(path: fileURL.path))
            
        } catch {
            lastError = error
            errorBus?.report(error, from: "SuperJournalService", severity: .critical)
        }
    }
    
    private func writeEntry(_ entry: SuperJournalEntry) async throws {
        guard let handle = currentFileHandle else {
            throw NSError(
                domain: "SuperJournalService",
                code: 2,
                userInfo: [NSLocalizedDescriptionKey: "No file handle available"]
            )
        }
        
        let content = entry.formatted() + "\n\n"
        
        guard let data = content.data(using: .utf8) else {
            throw NSError(
                domain: "SuperJournalService",
                code: 3,
                userInfo: [NSLocalizedDescriptionKey: "Failed to encode message"]
            )
        }
        
        handle.seekToEndOfFile()
        handle.write(data)
    }
    
    private func rotateFile() async {
        let oldPath = currentFilePath ?? ""
        
        // Close current file
        try? currentFileHandle?.close()
        currentFileHandle = nil
        
        // Create new file
        createNewFile()
        
        if let newPath = currentFilePath {
            eventBus?.publish(SuperJournalEvent.fileRotated(
                oldPath: oldPath,
                newPath: newPath
            ))
        }
    }
    
    private func formatLocalTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        formatter.timeZone = .current
        
        return formatter.string(from: date) + " " +
               (TimeZone.current.abbreviation() ?? TimeZone.current.identifier)
    }
    
    // MARK: - Cleanup
    deinit {
        try? currentFileHandle?.close()
    }
}