//
//  MessageRow.swift
//  atomic-aether
//
//  Individual message display with optional speaker label
//
//  ATOM 9: Scrollback Message Area - Message row component
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
                .padding(.top, 8)
                .padding(.bottom, 4)
                .padding(.leading, 8)
            }
            
            // Message content
            HStack {
                Text(message.content)
                    .font(.system(size: 15))
                    .foregroundColor(.white.opacity(0.9))
                    .textSelection(.enabled)
                
                // Streaming indicator
                if message.isStreaming {
                    ProgressView()
                        .scaleEffect(0.5)
                        .padding(.leading, 4)
                }
                
                Spacer()
            }
            .padding(.leading, 16)
            .padding(.bottom, isLastFromSpeaker ? 16 : appearance.messageSpacing)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}