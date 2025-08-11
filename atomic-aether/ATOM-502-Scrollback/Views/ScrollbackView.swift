//
//  ScrollbackView.swift
//  atomic-aether
//
//  Main scrollback view displaying all messages
//
//  ATOM 502: Scrollback - Main scrollback component
//
//  Atomic LEGO: Pure presentation layer for message display
//  700px width centered layout matching input bar
//

import SwiftUI
import Combine

struct ScrollbackView: View {
    @EnvironmentObject var messageStore: MessageStore
    @EnvironmentObject var personaStateService: PersonaStateService
    @EnvironmentObject var configBus: ConfigBus
    @EnvironmentObject var stateBus: StateBus
    @EnvironmentObject var eventBus: EventBus
    
    @State private var appearance: ScrollbackAppearance?
    @State private var contentWidth: CGFloat = 700 // Default fallback
    @State private var cancellables = Set<AnyCancellable>()
    
    var body: some View {
        if let appearance = appearance {
            ScrollViewReader { proxy in
                ScrollView {
                    VStack(alignment: .leading, spacing: 0) {
                        ForEach(Array(messageStore.messages.enumerated()), id: \.element.id) { index, message in
                            MessageRow(
                                message: message,
                                showSpeakerLabel: shouldShowSpeakerLabel(at: index),
                                isLastFromSpeaker: isLastFromSpeaker(at: index),
                                personaStateService: personaStateService,
                                appearance: appearance
                            )
                            .id(message.id)
                        }
                    }
                    .padding(.horizontal, appearance.padding)
                    .padding(.top, appearance.padding)
                }
                .frame(width: contentWidth)
                .scrollIndicators(.hidden)
                .onAppear {
                    setupWithConfigBus()
                    subscribeToContentWidth()
                    subscribeToMessagesLoaded(proxy: proxy)
                    
                    // Auto-scroll to latest message if messages exist
                    if let lastMessage = messageStore.messages.last {
                        withAnimation {
                            proxy.scrollTo(lastMessage.id, anchor: .bottom)
                        }
                    }
                }
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
    
    private func subscribeToContentWidth() {
        // Get initial width
        if let width = stateBus.get(StateKey.contentWidth) {
            contentWidth = width
        }
        
        // Subscribe to width changes
        eventBus.subscribe(to: StateChangedEvent.self) { event in
            if event.key == StateKey.contentWidth.name,
               let width = event.newValue as? CGFloat {
                contentWidth = width
            }
        }
        .store(in: &cancellables)
    }
    
    private func subscribeToMessagesLoaded(proxy: ScrollViewProxy) {
        // Subscribe to MessagesLoaded event to auto-scroll when messages are restored
        eventBus.subscribe(to: MessagesLoaded.self) { event in
            // Small delay to ensure layout is complete
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                if let lastMessage = messageStore.messages.last {
                    proxy.scrollTo(lastMessage.id, anchor: .bottom)
                }
            }
        }
        .store(in: &cancellables)
        
        // Also subscribe to MessageAddedEvent for new messages
        eventBus.subscribe(to: MessageAddedEvent.self) { event in
            // Small delay to ensure layout is complete
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                proxy.scrollTo(event.message.id, anchor: .bottom)
            }
        }
        .store(in: &cancellables)
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