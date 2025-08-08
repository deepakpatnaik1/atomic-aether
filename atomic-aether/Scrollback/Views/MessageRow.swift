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
    let personaStateService: PersonaStateService
    let appearance: ScrollbackAppearance
    @EnvironmentObject var bossProfileService: BossProfileService
    
    var body: some View {
        HStack(alignment: .top, spacing: appearance.message.contentLeadingPadding) {
            // Speaker label column (always present for alignment)
            if showSpeakerLabel {
                SpeakerLabel(
                    displayName: displayName(for: message.speaker),
                    accentColor: accentColor(for: message.speaker),
                    appearance: appearance.speakerLabel
                )
            } else {
                // Empty spacer to maintain alignment when speaker label is hidden
                Color.clear
                    .frame(width: appearance.speakerLabel.labelWidth, height: 1)
            }
            
            // Message content column
            VStack(alignment: .leading, spacing: 0) {
                Text(message.content)
                    .font(.system(size: appearance.message.fontSize))
                    .foregroundColor(.white.opacity(appearance.message.contentOpacity))
                    .textSelection(.enabled)
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                // Streaming indicator
                if message.isStreaming {
                    ProgressView()
                        .scaleEffect(appearance.message.progressIndicatorScale)
                        .padding(.top, appearance.message.progressIndicatorPadding)
                }
            }
        }
        .padding(.bottom, isLastFromSpeaker ? appearance.message.lastMessageBottomPadding : appearance.messageSpacing)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    // MARK: - Helper Methods
    
    private func displayName(for speakerId: String) -> String {
        // Special case for Boss - from BossProfileService
        if speakerId.lowercased() == "boss" {
            return bossProfileService.bossDisplayName
        }
        
        if let persona = personaStateService.configuration.persona(for: speakerId) {
            return persona.displayName
        }
        // Fallback for unknown speakers
        return speakerId.capitalized
    }
    
    private func accentColor(for speakerId: String) -> Color {
        // Special case for Boss - from BossProfileService
        if speakerId.lowercased() == "boss" {
            return bossProfileService.bossColor
        }
        
        if let persona = personaStateService.configuration.persona(for: speakerId) {
            return persona.color
        }
        // Default color for unknown speakers
        return Color(hex: appearance.message.unknownSpeakerColor) ?? Color.gray
    }
}