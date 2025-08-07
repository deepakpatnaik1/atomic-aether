//
//  ScrollbackHistoryLoaderService.swift
//  atomic-aether
//
//  Loads historical conversations from SuperJournal files
//
//  ATOM 30: Scrollback History Loader - Core service
//
//  Atomic LEGO: Reads SuperJournal files and converts to messages
//  Maintains loading state and handles pagination
//

import Foundation
import Combine

@MainActor
class ScrollbackHistoryLoaderService: ObservableObject {
    // MARK: - Published Properties
    @Published private(set) var isLoading = false
    @Published private(set) var hasMoreHistory = true
    @Published private(set) var oldestLoadedDate: Date?
    @Published private(set) var loadError: Error?
    
    // MARK: - Private Properties
    private var configuration: ScrollbackHistoryConfiguration = .default
    private var loadedFiles: Set<String> = []
    private var retryCount = 0
    
    // MARK: - Dependencies
    private var configBus: ConfigBus?
    private var eventBus: EventBus?
    private var errorBus: ErrorBus?
    private weak var messageStore: MessageStore?
    
    // MARK: - Setup
    func setup(
        configBus: ConfigBus,
        eventBus: EventBus,
        errorBus: ErrorBus,
        messageStore: MessageStore
    ) {
        self.configBus = configBus
        self.eventBus = eventBus
        self.errorBus = errorBus
        self.messageStore = messageStore
        
        loadConfiguration()
    }
    
    private func loadConfiguration() {
        if let config = configBus?.load("ScrollbackHistory", as: ScrollbackHistoryConfiguration.self) {
            self.configuration = config
        }
    }
    
    // MARK: - Public Interface
    
    /// Load the next batch of historical messages
    func loadMoreHistory() async {
        guard configuration.enabled,
              !isLoading,
              hasMoreHistory else { return }
        
        isLoading = true
        loadError = nil
        
        eventBus?.publish(ScrollbackHistoryEvent.loadingStarted)
        
        do {
            let messages = try await loadNextBatch()
            
            if messages.isEmpty {
                hasMoreHistory = false
                eventBus?.publish(ScrollbackHistoryEvent.noMoreHistory)
            } else {
                // Prepend messages to store
                await messageStore?.prependHistoricalMessages(messages)
                
                eventBus?.publish(ScrollbackHistoryEvent.messagesLoaded(
                    count: messages.count,
                    oldestDate: messages.last?.timestamp ?? Date()
                ))
                
                retryCount = 0
            }
        } catch {
            loadError = error
            handleLoadError(error)
        }
        
        isLoading = false
    }
    
    // MARK: - Private Methods
    
    private func loadNextBatch() async throws -> [Message] {
        guard let superJournalURL = configuration.superJournalURL else {
            throw ScrollbackHistoryError.invalidPath
        }
        
        // Get list of journal files
        let files = try FileManager.default.contentsOfDirectory(
            at: superJournalURL,
            includingPropertiesForKeys: [.creationDateKey],
            options: [.skipsHiddenFiles]
        )
        
        // Filter JSON files and sort by date (newest first)
        let journalFiles = files
            .filter { $0.pathExtension == "json" }
            .filter { !loadedFiles.contains($0.lastPathComponent) }
            .sorted { file1, file2 in
                let date1 = try? file1.resourceValues(forKeys: [.creationDateKey]).creationDate ?? Date.distantPast
                let date2 = try? file2.resourceValues(forKeys: [.creationDateKey]).creationDate ?? Date.distantPast
                return date1! > date2!
            }
        
        guard !journalFiles.isEmpty else {
            return []
        }
        
        // Load the next file
        let fileToLoad = journalFiles.first!
        let data = try Data(contentsOf: fileToLoad)
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        
        let journalFile = try decoder.decode(SuperJournalFile.self, from: data)
        
        // Mark file as loaded
        loadedFiles.insert(fileToLoad.lastPathComponent)
        
        // Update oldest loaded date
        if let lastMessage = journalFile.messages.last {
            oldestLoadedDate = lastMessage.timestamp
        }
        
        // Convert to app messages and limit by batch size
        let messages = journalFile.messages
            .prefix(configuration.messagesPerBatch)
            .map { $0.toMessage() }
        
        return messages
    }
    
    private func handleLoadError(_ error: Error) {
        let errorMessage: String
        
        switch error {
        case let scrollbackError as ScrollbackHistoryError:
            errorMessage = scrollbackError.localizedDescription
        case let decodingError as DecodingError:
            errorMessage = "Failed to parse journal file: \(decodingError.localizedDescription)"
        default:
            errorMessage = "Failed to load history: \(error.localizedDescription)"
        }
        
        errorBus?.report(
            message: errorMessage,
            from: "ScrollbackHistory",
            severity: .warning
        )
        
        eventBus?.publish(ScrollbackHistoryEvent.loadingFailed(error))
        
        // Retry logic
        if retryCount < configuration.maxRetries {
            retryCount += 1
            Task {
                try await Task.sleep(nanoseconds: UInt64(configuration.errorRetryDelay * 1_000_000_000))
                await loadMoreHistory()
            }
        }
    }
    
    /// Reset loading state (e.g., when starting new session)
    func reset() {
        loadedFiles.removeAll()
        oldestLoadedDate = nil
        hasMoreHistory = true
        retryCount = 0
        loadError = nil
    }
}

// MARK: - Errors

enum ScrollbackHistoryError: LocalizedError {
    case invalidPath
    case noMessagesFound
    case decodingFailed(String)
    
    var errorDescription: String? {
        switch self {
        case .invalidPath:
            return "Invalid SuperJournal path"
        case .noMessagesFound:
            return "No messages found in file"
        case .decodingFailed(let details):
            return "Failed to decode journal: \(details)"
        }
    }
}