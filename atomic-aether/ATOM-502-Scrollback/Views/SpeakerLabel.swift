//
//  SpeakerLabel.swift
//  atomic-aether
//
//  Speaker label with colored border
//
//  ATOM 502: Scrollback - Speaker label component
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
        HStack(alignment: .top, spacing: appearance.stackSpacing) {
            // Colored left border
            Rectangle()
                .fill(accentColor)
                .frame(width: appearance.borderWidth)
            
            // Speaker name
            Text(displayName)
                .font(.system(size: appearance.fontSize, weight: .medium))
                .foregroundColor(.white.opacity(appearance.nameOpacity))
                .padding(.horizontal, appearance.namePaddingHorizontal)
                .padding(.vertical, appearance.namePaddingVertical)
                .background(
                    RoundedRectangle(cornerRadius: appearance.cornerRadius)
                        .fill(Color.white.opacity(appearance.backgroundOpacity))
                )
            
            Spacer(minLength: 0)
        }
        .frame(width: appearance.labelWidth, alignment: .topLeading)
    }
}