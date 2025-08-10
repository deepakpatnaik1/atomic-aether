//
//  SpeakerLabel.swift
//  atomic-aether
//
//  Speaker label with name display
//
//  ATOM 502: Scrollback - Speaker label component
//
//  Atomic LEGO: Reusable speaker label with persona styling
//  Clean, minimal design without borders
//

import SwiftUI

struct SpeakerLabel: View {
    let displayName: String
    let accentColor: Color
    let appearance: ScrollbackAppearance.SpeakerLabelAppearance
    
    var body: some View {
        HStack(spacing: 0) {
            // Colored left border
            Rectangle()
                .fill(accentColor.opacity(appearance.borderOpacity))
                .frame(width: appearance.borderWidth)
            
            // Speaker name with background
            Text(displayName)
                .font(.system(size: appearance.fontSize, weight: .medium))
                .foregroundColor(.white.opacity(appearance.nameOpacity))
                .padding(.horizontal, appearance.namePaddingHorizontal)
                .padding(.vertical, appearance.namePaddingVertical)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(
                    Color.white.opacity(appearance.backgroundOpacity)
                )
        }
        .clipShape(RoundedRectangle(cornerRadius: appearance.cornerRadius))
        .fixedSize(horizontal: true, vertical: true)
    }
}