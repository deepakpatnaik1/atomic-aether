//
//  ScrollbackAppearance.swift
//  atomic-aether
//
//  Scrollback UI configuration model
//
//  ATOM 502: Scrollback - Appearance configuration
//
//  Atomic LEGO: Maps to ScrollbackAppearance.json
//  All visual properties externalized to configuration
//

import Foundation

struct ScrollbackAppearance: Codable {
    let width: Double
    let padding: Double
    let messageSpacing: Double
    let speakerLabel: SpeakerLabelAppearance
    let message: MessageAppearance
    
    struct SpeakerLabelAppearance: Codable {
        let fontSize: Double
        let borderWidth: Double
        let nameOpacity: Double
        let backgroundOpacity: Double
        let namePaddingHorizontal: Double
        let namePaddingVertical: Double
        let cornerRadius: Double
        let stackSpacing: Double
        let labelWidth: Double
    }
    
    struct MessageAppearance: Codable {
        let fontSize: Double
        let contentOpacity: Double
        let topPadding: Double
        let bottomPadding: Double
        let leadingPadding: Double
        let contentLeadingPadding: Double
        let lastMessageBottomPadding: Double
        let progressIndicatorScale: Double
        let progressIndicatorPadding: Double
        let stackSpacing: Double
        let unknownSpeakerColor: String
    }
}