//
//  ColorMeteor.swift
//  atomic-aether
//
//  Horizontal gradient line extending from speaker name
//
//  ATOM 502: Scrollback - Color meteor effect component
//
//  Atomic LEGO: Reusable gradient line with persona colors
//  Creates visual connection from speaker to message edge
//

import SwiftUI

struct ColorMeteor: View {
    let accentColor: Color
    let appearance: ScrollbackAppearance.ColorMeteorAppearance
    
    var body: some View {
        ZStack {
            // Background layer - blurred for glow effect
            LinearGradient(
                gradient: Gradient(stops: [
                    .init(color: accentColor.opacity(appearance.endOpacity), location: 0.0),
                    .init(color: accentColor.opacity(appearance.midOpacity), location: appearance.midLocation),
                    .init(color: accentColor.opacity(appearance.startOpacity), location: 1.0)
                ]),
                startPoint: .leading,
                endPoint: .trailing
            )
            .frame(height: appearance.height)
            .blur(radius: appearance.blurRadius)
            
            // Foreground layer - sharp line
            LinearGradient(
                gradient: Gradient(stops: [
                    .init(color: accentColor.opacity(appearance.endOpacity), location: 0.0),
                    .init(color: accentColor.opacity(appearance.midOpacity * 0.8), location: appearance.midLocation),
                    .init(color: accentColor.opacity(appearance.startOpacity * 0.9), location: 1.0)
                ]),
                startPoint: .leading,
                endPoint: .trailing
            )
            .frame(height: appearance.sharpLineHeight)
        }
        .padding(.trailing, appearance.rightPadding)
    }
}