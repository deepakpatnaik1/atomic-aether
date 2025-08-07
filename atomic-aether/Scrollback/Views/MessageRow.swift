//
//  MessageRow.swift
//  atomic-aether
//
//  Individual message display with optional speaker label
//
//  ATOM 15: Scrollback - Message row component
//
//  Atomic LEGO: Displays a single message with appropriate styling
//  Shows speaker label only when speaker changes
//

import SwiftUI

struct MessageRow: View {
    let message: Message
    let showSpeakerLabel: Bool
    let isLastFromSpeaker: Bool
    let personaService: PersonaService
    let appearance: ScrollbackAppearance
    
    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            // Speaker label (only shown when speaker changes)
            if showSpeakerLabel {
                SpeakerLabel(
                    displayName: personaService.displayName(for: message.speaker),
                    accentColor: personaService.accentColor(for: message.speaker),
                    appearance: appearance.speakerLabel
                )
                .padding(.top, appearance.message.topPadding)
                .padding(.bottom, appearance.message.bottomPadding)
                .padding(.leading, appearance.message.leadingPadding)
            }
            
            // Message content
            HStack {
                Text(message.content)
                    .font(.system(size: appearance.message.fontSize))
                    .foregroundColor(.white.opacity(appearance.message.contentOpacity))
                    .textSelection(.enabled)
                
                // Streaming indicator
                if message.isStreaming {
                    ProgressView()
                        .scaleEffect(appearance.message.progressIndicatorScale)
                        .padding(.leading, appearance.message.progressIndicatorPadding)
                }
                
                Spacer()
            }
            .padding(.leading, appearance.message.contentLeadingPadding)
            .padding(.bottom, isLastFromSpeaker ? appearance.message.lastMessageBottomPadding : appearance.messageSpacing)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}