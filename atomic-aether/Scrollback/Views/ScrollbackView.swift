//
//  ScrollbackView.swift
//  atomic-aether
//
//  Main scrollback view displaying all messages
//
//  ATOM 9: Scrollback Message Area - Main scrollback component
//
//  Atomic LEGO: Pure presentation layer for message display
//  700px width centered layout matching input bar
//

import SwiftUI

struct ScrollbackView: View {
    @EnvironmentObject var messageStore: MessageStore
    @EnvironmentObject var personaService: PersonaService
    @EnvironmentObject var configBus: ConfigBus
    @EnvironmentObject var historyLoader: ScrollbackHistoryLoaderService
    
    @State private var appearance = ScrollbackAppearance(
        width: 700,
        padding: 20,
        messageSpacing: 4,
        speakerLabel: ScrollbackAppearance.SpeakerLabelAppearance(
            fontSize: 13,
            borderWidth: 2,
            gradientLineHeight: 1,
            gradientLinePadding: 112,
            nameOpacity: 0.85,
            backgroundOpacity: 0.05,
            gradientStartOpacity: 0.0,
            gradientMidOpacity: 0.3,
            gradientEndOpacity: 0.6
        ),
        message: ScrollbackAppearance.MessageAppearance(
            fontSize: 15,
            contentOpacity: 0.9,
            topPadding: 8,
            bottomPadding: 4,
            leadingPadding: 8,
            contentLeadingPadding: 16,
            lastMessageBottomPadding: 16,
            progressIndicatorScale: 0.5,
            progressIndicatorPadding: 4
        )
    )
    
    var body: some View {
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
                            personaService: personaService,
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
    }
    
    private func setupWithConfigBus() {
        // Load appearance configuration
        if let config = configBus.load("ScrollbackAppearance", as: ScrollbackAppearance.self) {
            appearance = config
        }
        
        // Setup persona service
        personaService.setupWithConfigBus(configBus)
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