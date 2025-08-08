//
//  ScrollbackView.swift
//  atomic-aether
//
//  Main scrollback view displaying all messages
//
//  ATOM 15: Scrollback - Main scrollback component
//
//  Atomic LEGO: Pure presentation layer for message display
//  700px width centered layout matching input bar
//

import SwiftUI

struct ScrollbackView: View {
    @EnvironmentObject var messageStore: MessageStore
    @EnvironmentObject var personaStateService: PersonaStateService
    @EnvironmentObject var configBus: ConfigBus
    @EnvironmentObject var historyLoader: ScrollbackHistoryLoaderService
    
    @State private var appearance: ScrollbackAppearance?
    
    var body: some View {
        if let appearance = appearance {
            ScrollViewReader { proxy in
                ScrollView {
                    VStack(alignment: .leading, spacing: 0) {
                        // History loader trigger (Phase II)
                        ScrollbackHistoryTriggerView()
                            .padding(.bottom, appearance.messageSpacing)
                        
                        ForEach(Array(messageStore.messages.enumerated()), id: \.element.id) { index, message in
                            MessageRow(
                                message: message,
                                showSpeakerLabel: shouldShowSpeakerLabel(at: index),
                                isLastFromSpeaker: isLastFromSpeaker(at: index),
                                personaStateService: personaStateService,
                                appearance: appearance
                            )
                        }
                    }
                    .padding(.horizontal, appearance.padding)
                    .padding(.top, appearance.padding)
                }
                .frame(width: appearance.width)
                .scrollIndicators(.hidden)
            }
            .onAppear {
                setupWithConfigBus()
            }
        } else {
            // Minimal fallback if config fails to load
            ScrollView {
                Text("Loading...")
                    .foregroundColor(.gray)
            }
            .onAppear {
                setupWithConfigBus()
            }
        }
    }
    
    private func setupWithConfigBus() {
        // Load appearance configuration
        if let config = configBus.load("ScrollbackAppearance", as: ScrollbackAppearance.self) {
            appearance = config
        }
    }
    
    private func shouldShowSpeakerLabel(at index: Int) -> Bool {
        guard index < messageStore.messages.count else { return false }
        if index == 0 { return true }
        
        let currentMessage = messageStore.messages[index]
        let previousMessage = messageStore.messages[index - 1]
        return currentMessage.speaker != previousMessage.speaker
    }
    
    private func isLastFromSpeaker(at index: Int) -> Bool {
        guard index < messageStore.messages.count else { return true }
        if index == messageStore.messages.count - 1 { return true }
        
        let currentMessage = messageStore.messages[index]
        let nextMessage = messageStore.messages[index + 1]
        return currentMessage.speaker != nextMessage.speaker
    }
}