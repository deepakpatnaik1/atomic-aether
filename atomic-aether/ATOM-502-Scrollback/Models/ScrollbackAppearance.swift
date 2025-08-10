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
    let padding: Double
    let messageSpacing: Double
    let speakerLabel: SpeakerLabelAppearance
    let message: MessageAppearance
    let colorMeteor: ColorMeteorAppearance
    
    struct SpeakerLabelAppearance: Codable {
        let fontSize: Double
        let borderWidth: Double
        let borderOpacity: Double
        let nameOpacity: Double
        let backgroundOpacity: Double
        let namePaddingHorizontal: Double
        let namePaddingVertical: Double
        let cornerRadius: Double
        let stackSpacing: Double
        let labelWidth: Double
        let verticalSpacing: Double
    }
    
    struct ColorMeteorAppearance: Codable {
        let height: Double
        let sharpLineHeight: Double
        let startOpacity: Double
        let midOpacity: Double
        let endOpacity: Double
        let midLocation: Double
        let blurRadius: Double
        let rightPadding: Double
    }
    
    struct MessageAppearance: Codable {
        let fontSize: Double
        let contentOpacity: Double
        let textColor: String
        let topPadding: Double
        let bottomPadding: Double
        let leadingPadding: Double
        let contentLeadingPadding: Double
        let lastMessageBottomPadding: Double
        let progressIndicatorScale: Double
        let progressIndicatorPadding: Double
        let stackSpacing: Double
        let unknownSpeakerColor: String
        let leftIndent: Double
    }
}