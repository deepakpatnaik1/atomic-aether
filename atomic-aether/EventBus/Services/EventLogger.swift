//
//  EventLogger.swift
//  atomic-aether
//
//  Debug logging for event flow
//
//  ATOM 5: EventBus - Event logging and debugging
//
//  ATOMIC LEGO: Pure logging service
//  - Subscribes to all events for debugging
//  - Configurable log levels and filtering
//  - Can be completely removed without affecting system
//

import Foundation
import Combine
import os.log

@MainActor
final class EventLogger: ObservableObject {
    
    // MARK: - Properties
    
    private let logger = Logger(subsystem: "\(Bundle.main.bundleIdentifier ?? "com.unknown").eventbus", category: "events")
    private var subscriptions = Set<AnyCancellable>()
    private let eventBus: any EventBusProtocol
    
    @Published var isLoggingEnabled: Bool = false
    @Published var logLevel: LogLevel = .info
    @Published var eventHistory: [LoggedEvent] = []
    
    // MARK: - Configuration
    
    enum LogLevel: String, CaseIterable {
        case debug = "Debug"
        case info = "Info"
        case warning = "Warning"
        case error = "Error"
        
        var osLogType: OSLogType {
            switch self {
            case .debug: return .debug
            case .info: return .info
            case .warning: return .default
            case .error: return .error
            }
        }
    }
    
    // MARK: - Logged Event Model
    
    struct LoggedEvent: Identifiable {
        let id = UUID()
        let timestamp: Date
        let eventType: String
        let source: String
        let details: String
        let level: LogLevel
    }
    
    // MARK: - Initialization
    
    init(eventBus: any EventBusProtocol) {
        self.eventBus = eventBus
        setupEventLogging()
    }
    
    // MARK: - Event Logging Setup
    
    private func setupEventLogging() {
        // Subscribe to all events
        eventBus.events
            .sink { [weak self] event in
                self?.logEvent(event)
            }
            .store(in: &subscriptions)
    }
    
    // MARK: - Logging Methods
    
    private func logEvent(_ event: AetherEvent) {
        guard isLoggingEnabled else { return }
        
        let eventType = String(describing: type(of: event))
        let details = formatEventDetails(event)
        
        // Log to system
        logger.log(
            level: logLevel.osLogType,
            "[\(eventType)] from \(event.source): \(details)"
        )
        
        // Store in history (keep last 100 events)
        let loggedEvent = LoggedEvent(
            timestamp: event.timestamp,
            eventType: eventType,
            source: event.source,
            details: details,
            level: logLevel
        )
        
        eventHistory.append(loggedEvent)
        if eventHistory.count > 100 {
            eventHistory.removeFirst()
        }
    }
    
    private func formatEventDetails(_ event: AetherEvent) -> String {
        switch event {
        case let inputEvent as InputEvent:
            return formatInputEvent(inputEvent)
        case let systemEvent as SystemEvent:
            return formatSystemEvent(systemEvent)
        case let conversationEvent as ConversationEvent:
            return formatConversationEvent(conversationEvent)
        case let navigationEvent as NavigationEvent:
            return formatNavigationEvent(navigationEvent)
        case let stateEvent as StateEventType:
            return formatStateEvent(stateEvent)
        case let personaEvent as PersonaSwitchedEvent:
            return "Persona switched: \(personaEvent.fromPersona) → \(personaEvent.toPersona)"
        case let personaEvent as PersonaMessageProcessedEvent:
            return "Persona message: \(personaEvent.persona) - '\(personaEvent.cleanedMessage.prefix(50))...'"
        case let personaEvent as InvalidPersonaEvent:
            return "Invalid persona: \(personaEvent.attemptedPersona)"
        case let modelEvent as ModelSelectedEvent:
            return "Model selected: \(modelEvent.model)"
        case is ModelDefaultsChangedEvent:
            return "Model defaults changed"
        case let modelEvent as ModelOverrideClearedEvent:
            return "Model override cleared: \(modelEvent.isAnthropic ? "Anthropic" : "Non-Anthropic")"
        // ConversationFlow events
        case let event as ConversationStartedEvent:
            return "Conversation started with \(event.persona) using \(event.model)"
        case let event as ConversationMessageSentEvent:
            return "Message sent to \(event.persona): \(event.content.prefix(50))..."
        case let event as ConversationResponseReceivedEvent:
            return "Response received from \(event.persona)"
        case let event as ConversationStreamingEvent:
            return "Streaming response (\(event.contentLength) chars)"
        case let event as ConversationStreamCompletedEvent:
            return "Stream completed (\(event.success ? "success" : "failed"))"
        case let event as ConversationErrorEvent:
            return "Conversation error: \(event.error)"
        // LLM events
        case let event as LLMEvent:
            return formatLLMEvent(event)
        default:
            return "Unknown event"
        }
    }
    
    // MARK: - Event Formatters
    
    private func formatInputEvent(_ event: InputEvent) -> String {
        switch event {
        case .textChanged(let text, _):
            return "Text changed: '\(text.prefix(50))...'"
        case .textSubmitted(let text, _):
            return "Text submitted: '\(text)'"
        case .keyPressed(let key, let modifiers, _):
            return "Key pressed: \(key) with modifiers: \(modifiers)"
        case .fileDropped(let files, _):
            return "Files dropped: \(files.count) files"
        case .filePasted(_, let type, _):
            return "File pasted: \(type)"
        case .slashCommandEntered(let command, _):
            return "Slash command: \(command)"
        case .focusChanged(let isFocused, _):
            return "Focus changed: \(isFocused ? "gained" : "lost")"
        }
    }
    
    private func formatSystemEvent(_ event: SystemEvent) -> String {
        switch event {
        case .appLaunched:
            return "App launched"
        case .appWillTerminate:
            return "App will terminate"
        case .configurationLoaded(let config, _):
            return "Configuration loaded: \(config)"
        case .configurationFailed(let error, _):
            return "Configuration failed: \(error)"
        case .serviceStarted(let service, _):
            return "Service started: \(service)"
        case .serviceStopped(let service, _):
            return "Service stopped: \(service)"
        case .themeChanged(let theme, _):
            return "Theme changed: \(theme)"
        case .modelChanged(let model, let provider, _):
            return "Model changed: \(provider):\(model)"
        }
    }
    
    private func formatConversationEvent(_ event: ConversationEvent) -> String {
        switch event {
        case .personaDetected(let name, let message, _):
            return "Persona detected: \(name) in '\(message.prefix(30))...'"
        case .personaSwitched(let from, let to, _):
            return "Persona switched: \(from ?? "none") → \(to)"
        case .messageComposed(let content, let attachments, _):
            return "Message composed: '\(content.prefix(50))...' with \(attachments.count) attachments"
        case .messageSent(let id, _, let persona, _):
            return "Message sent: \(id) to \(persona)"
        case .responseReceived(let id, _, let persona, _):
            return "Response received: \(id) from \(persona)"
        case .responseStreaming(let id, let content, _):
            return "Response streaming: \(id) (\(content.count) chars)"
        case .turnSaved(let id, let path, _):
            return "Turn saved: \(id) to \(path)"
        case .memoryUpdated(let type, _):
            return "Memory updated: \(type)"
        }
    }
    
    private func formatNavigationEvent(_ event: NavigationEvent) -> String {
        switch event {
        case .turnModeEntered:
            return "Turn mode entered"
        case .turnModeExited:
            return "Turn mode exited"
        case .navigatedToTurn(let id, let index, _):
            return "Navigated to turn: \(index) (id: \(id))"
        case .scrolledToPosition(let position, _):
            return "Scrolled to position: \(position)"
        case .scrolledToMessage(let id, _):
            return "Scrolled to message: \(id)"
        case .focusRequested(let target, _):
            return "Focus requested: \(target)"
        case .viewAppeared(let view, _):
            return "View appeared: \(view)"
        case .viewDisappeared(let view, _):
            return "View disappeared: \(view)"
        }
    }
    
    private func formatStateEvent(_ event: StateEventType) -> String {
        switch event {
        case let changed as StateChangedEvent:
            return "State changed: \(changed.key)"
        case is StateClearedEvent:
            return "State cleared"
        default:
            return "State event"
        }
    }
    
    private func formatLLMEvent(_ event: LLMEvent) -> String {
        switch event {
        case .requestStarted(let model, let messageCount, _):
            return "LLM request started: \(model) with \(messageCount) messages"
        case .tokenReceived(let token, let model, _):
            return "Token received from \(model): \(token.prefix(20))..."
        case .responseCompleted(let model, let totalTokens, let duration, _):
            let tokenInfo = totalTokens.map { " (\($0) tokens)" } ?? ""
            return "Response completed: \(model)\(tokenInfo) in \(String(format: "%.2f", duration))s"
        case .errorOccurred(let error, let model, _):
            return "LLM error from \(model): \(error)"
        case .streamingToggled(let enabled, _):
            return "Streaming \(enabled ? "enabled" : "disabled")"
        }
    }
    
    // MARK: - Public Methods
    
    func clearHistory() {
        eventHistory.removeAll()
    }
    
    func exportLogs() -> String {
        eventHistory.map { event in
            "[\(event.timestamp.ISO8601Format())] [\(event.level.rawValue)] [\(event.eventType)] \(event.source): \(event.details)"
        }.joined(separator: "\n")
    }
}