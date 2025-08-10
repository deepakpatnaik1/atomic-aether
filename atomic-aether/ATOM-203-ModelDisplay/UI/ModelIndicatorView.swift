//
//  ModelIndicatorView.swift
//  atomic-aether
//
//  Reusable model indicator component
//
//  ATOM 203: Model Display - UI Component
//
//  Atomic LEGO: Pure UI component that displays current model
//  Gets data from ModelDisplayService
//

import SwiftUI

struct ModelIndicatorView: View {
    @ObservedObject var modelDisplayService: ModelDisplayService
    let fontSize: CGFloat
    let opacity: Double
    
    var body: some View {
        Text(modelDisplayService.currentModelDisplay)
            .font(.system(size: fontSize))
            .foregroundColor(.white.opacity(opacity))
    }
}