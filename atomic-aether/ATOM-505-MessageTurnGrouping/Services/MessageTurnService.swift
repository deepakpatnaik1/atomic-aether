//
//  MessageTurnService.swift
//  atomic-aether
//
//  Service that groups messages into conversation turns
//
//  ATOM 505: MessageTurnGrouping - Core service
//
//  Atomic LEGO: Transforms messages into turns
//  Subscribes to message events, publishes turn events
//

import Foundation
import SwiftUI
import Combine

@MainActor
class MessageTurnService: ObservableObject {
    @Published private(set) var turns: [MessageTurn] = []
    
    private var configuration: MessageTurnConfiguration = .default
    private var configBus: ConfigBus?
    private var eventBus: EventBus?
    private var messageStore: MessageStore?
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        // Dependencies injected via setup()
    }
    
    func setup(configBus: ConfigBus, eventBus: EventBus, messageStore: MessageStore) {
        self.configBus = configBus
        self.eventBus = eventBus
        self.messageStore = messageStore
        
        // Load configuration
        if let config = configBus.load("MessageTurnGrouping", as: MessageTurnConfiguration.self) {
            self.configuration = config
        }
        
        // Subscribe to message events
        subscribeToMessageEvents()
        
        // Initial grouping
        updateTurns()
    }
    
    private func subscribeToMessageEvents() {
        // React to new messages
        eventBus?.subscribe(to: MessageAddedEvent.self) { [weak self] _ in
            self?.updateTurns()
        }
        .store(in: &cancellables)
        
        // React to message updates
        eventBus?.subscribe(to: MessageUpdatedEvent.self) { [weak self] _ in
            self?.updateTurns()
        }
        .store(in: &cancellables)
        
        // React to cleared messages
        eventBus?.subscribe(to: MessagesCleared.self) { [weak self] _ in
            self?.turns = []
            if self?.configuration.publishEvents == true {
                self?.eventBus?.publish(TurnsUpdatedEvent(turnCount: 0))
            }
        }
        .store(in: &cancellables)
        
        // React to loaded messages
        eventBus?.subscribe(to: MessagesLoaded.self) { [weak self] _ in
            self?.updateTurns()
        }
        .store(in: &cancellables)
    }
    
    private func updateTurns() {
        guard let messages = messageStore?.messages else { return }
        
        let newTurns = groupMessagesIntoTurns(messages)
        let oldCount = turns.count
        turns = newTurns
        
        // Publish event if enabled and count changed
        if configuration.publishEvents && oldCount != newTurns.count {
            eventBus?.publish(TurnCountChangedEvent(oldCount: oldCount, newCount: newTurns.count))
        }
        
        if configuration.publishEvents {
            eventBus?.publish(TurnsUpdatedEvent(turnCount: newTurns.count))
        }
    }
    
    // Pure function for grouping messages into turns
    func groupMessagesIntoTurns(_ messages: [Message]) -> [MessageTurn] {
        guard !messages.isEmpty else { return [] }
        
        var turns: [MessageTurn] = []
        var currentTurnMessages: [Message] = []
        var turnNumber = 1
        
        for message in messages {
            // Check if this starts a new turn
            let startsNewTurn = message.speaker == configuration.turnDelimiter && !currentTurnMessages.isEmpty
            
            if startsNewTurn {
                // Save current turn
                if !currentTurnMessages.isEmpty {
                    let turn = MessageTurn(
                        messages: currentTurnMessages,
                        turnNumber: turnNumber,
                        startedAt: currentTurnMessages.first?.timestamp ?? Date()
                    )
                    
                    // Apply filters
                    if configuration.includeSingleMessageTurns || turn.messageCount > 1 {
                        turns.append(turn)
                        turnNumber += 1
                    }
                }
                
                // Start new turn
                currentTurnMessages = [message]
            } else {
                // Continue current turn
                currentTurnMessages.append(message)
                
                // Check max messages limit
                if currentTurnMessages.count >= configuration.maxMessagesPerTurn {
                    let turn = MessageTurn(
                        messages: currentTurnMessages,
                        turnNumber: turnNumber,
                        startedAt: currentTurnMessages.first?.timestamp ?? Date()
                    )
                    turns.append(turn)
                    turnNumber += 1
                    currentTurnMessages = []
                }
            }
        }
        
        // Don't forget the last turn
        if !currentTurnMessages.isEmpty {
            let turn = MessageTurn(
                messages: currentTurnMessages,
                turnNumber: turnNumber,
                startedAt: currentTurnMessages.first?.timestamp ?? Date()
            )
            
            if configuration.includeSingleMessageTurns || turn.messageCount > 1 {
                turns.append(turn)
            }
        }
        
        return turns
    }
}