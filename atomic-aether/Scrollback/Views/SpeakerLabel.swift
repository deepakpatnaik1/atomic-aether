//
//  SpeakerLabel.swift
//  atomic-aether
//
//  Speaker label with colored border and gradient line
//
//  ATOM 9: Scrollback Message Area - Speaker label component
//
//  Atomic LEGO: Reusable speaker label with persona styling
//  Ported from original aether design
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
                .fill(accentColor)
                .frame(width: appearance.borderWidth)
            
            // Speaker name
            Text(displayName)
                .font(.system(size: appearance.fontSize, weight: .medium))
                .foregroundColor(.white.opacity(appearance.nameOpacity))
                .padding(.horizontal, 8)
                .padding(.vertical, 3)
                .background(
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.white.opacity(appearance.backgroundOpacity))
                )
            
            // Horizontal gradient line (starts from right, tapers to left)
            Rectangle()
                .fill(
                    LinearGradient(
                        colors: [
                            accentColor.opacity(appearance.gradientStartOpacity),
                            accentColor.opacity(appearance.gradientMidOpacity),
                            accentColor.opacity(appearance.gradientEndOpacity)
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .frame(height: appearance.gradientLineHeight)
                .padding(.leading, appearance.gradientLinePadding)
        }
        .clipShape(RoundedRectangle(cornerRadius: 4))
    }
}