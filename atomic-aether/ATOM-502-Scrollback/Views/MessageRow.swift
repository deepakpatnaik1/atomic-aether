//
//  MessageRow.swift
//  atomic-aether
//
//  Individual message display with optional speaker label
//
//  ATOM 502: Scrollback - Message row component
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
        VStack(alignment: .leading, spacing: 0) {
            // Speaker label row with color meteor (only when speaker changes)
            if showSpeakerLabel {
                HStack(spacing: 8) {
                    SpeakerLabel(
                        displayName: displayName(for: message.speaker),
                        accentColor: accentColor(for: message.speaker),
                        appearance: appearance.speakerLabel
                    )
                    
                    ColorMeteor(
                        accentColor: accentColor(for: message.speaker),
                        appearance: appearance.colorMeteor
                    )
                    .frame(maxWidth: .infinity)
                }
                .padding(.bottom, appearance.speakerLabel.verticalSpacing)
            }
            
            // Message content (indented)
            VStack(alignment: .leading, spacing: 0) {
                MarkdownMessageView(
                    content: message.content,
                    fontSize: appearance.message.fontSize,
                    opacity: appearance.message.contentOpacity,
                    textColor: Color(hex: appearance.message.textColor)
                )
                
                // Streaming indicator
                if message.isStreaming {
                    ProgressView()
                        .scaleEffect(appearance.message.progressIndicatorScale)
                        .padding(.top, appearance.message.progressIndicatorPadding)
                }
            }
            .padding(.leading, appearance.message.leftIndent)
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