//
//  ScrollbackAppearance.swift
//  atomic-aether
//
//  Scrollback UI configuration model
//
//  ATOM 9: Scrollback Message Area - Appearance configuration
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
    
    struct SpeakerLabelAppearance: Codable {
        let fontSize: Double
        let borderWidth: Double
        let gradientLineHeight: Double
        let gradientLinePadding: Double
    }
}