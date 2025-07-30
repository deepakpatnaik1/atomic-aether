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
    
    @State private var appearance = ScrollbackAppearance(
        width: 700,
        padding: 20,
        messageSpacing: 4,
        speakerLabel: ScrollbackAppearance.SpeakerLabelAppearance(
            fontSize: 13,
            borderWidth: 2,
            gradientLineHeight: 1,
            gradientLinePadding: 112
        )
    )
    
    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
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
            .onChange(of: messageStore.messages) {
                // Auto-scroll to bottom when new messages arrive
                withAnimation(.easeOut(duration: 0.3)) {
                    if let lastMessage = messageStore.messages.last {
                        proxy.scrollTo(lastMessage.id, anchor: .bottom)
                    }
                }
            }
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