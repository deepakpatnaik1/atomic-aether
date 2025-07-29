//
//  InputBarView.swift
//  atomic-aether
//
//  Pure visual input bar component with uniform padding
//
//  Atomic LEGO: UI-only, no behavior
//  Just appearance as defined in configuration
//

import SwiftUI

struct InputBarView: View {
    @StateObject private var appearanceService = InputBarAppearanceService()
    @FocusState private var isTextFieldFocused: Bool
    @State private var text = ""
    
    var body: some View {
        if let appearance = appearanceService.appearance {
            inputBar(appearance: appearance)
                .frame(width: appearance.dimensions.width)
                .padding(.bottom, appearance.dimensions.bottomMargin)
        } else if let error = appearanceService.loadError {
            // Error state
            Text("Error loading appearance: \(error)")
                .foregroundColor(.red)
                .padding()
        } else {
            // Loading state
            ProgressView()
                .padding()
        }
    }
    
    @ViewBuilder
    private func inputBar(appearance: InputBarAppearance) -> some View {
        VStack(spacing: appearance.padding.uniform) {
            // Text field
            TextField(appearance.textField.placeholder, text: $text)
                .textFieldStyle(.plain)
                .font(.system(size: appearance.textField.fontSize))
                .foregroundColor(InputBarAppearance.color(from: appearance.textField.textColor))
                .focused($isTextFieldFocused)
                .placeholder(when: text.isEmpty) {
                    Text(appearance.textField.placeholder)
                        .foregroundColor(.white.opacity(appearance.textField.placeholderOpacity))
                }
                .frame(minHeight: appearance.dimensions.textFieldMinHeight)
                .onAppear {
                    isTextFieldFocused = true
                }
            
            // Controls row
            HStack(spacing: appearance.controls.spacing) {
                Image(systemName: appearance.controls.plusButton.iconName)
                    .font(.system(size: appearance.controls.plusButton.size, weight: .medium))
                    .foregroundColor(.white.opacity(appearance.controls.plusButton.opacity))
                
                Text(appearance.controls.modelPicker.text)
                    .font(.system(size: appearance.controls.modelPicker.fontSize))
                    .foregroundColor(.white.opacity(appearance.controls.modelPicker.opacity))
                
                Spacer()
                
                Circle()
                    .fill(InputBarAppearance.color(from: appearance.controls.greenIndicator.color))
                    .frame(
                        width: appearance.controls.greenIndicator.size,
                        height: appearance.controls.greenIndicator.size
                    )
                    .shadow(
                        color: InputBarAppearance.color(from: appearance.controls.greenIndicator.color),
                        radius: appearance.controls.greenIndicator.glowRadius1
                    )
                    .shadow(
                        color: InputBarAppearance.color(from: appearance.controls.greenIndicator.color)
                            .opacity(appearance.controls.greenIndicator.glowOpacity),
                        radius: appearance.controls.greenIndicator.glowRadius2
                    )
            }
        }
        .padding(.vertical, appearance.padding.uniform)
        .padding(.horizontal, appearance.padding.horizontal)
        .frame(height: appearance.dimensions.defaultHeight)
        .background(
            glassmorphicBackground(appearance: appearance)
        )
    }
    
    @ViewBuilder
    private func glassmorphicBackground(appearance: InputBarAppearance) -> some View {
        RoundedRectangle(cornerRadius: appearance.dimensions.cornerRadius)
            .fill(Color.black.opacity(appearance.glassmorphic.backgroundOpacity))
            .overlay(
                RoundedRectangle(cornerRadius: appearance.dimensions.cornerRadius)
                    .stroke(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(appearance.glassmorphic.borderTopOpacity),
                                Color.white.opacity(appearance.glassmorphic.borderBottomOpacity)
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        ),
                        lineWidth: 1
                    )
            )
            .shadow(
                color: InputBarAppearance.color(from: appearance.shadows.outer.color)
                    .opacity(appearance.shadows.outer.opacity),
                radius: appearance.shadows.outer.radius,
                x: appearance.shadows.outer.x,
                y: appearance.shadows.outer.y
            )
            .shadow(
                color: InputBarAppearance.color(from: appearance.shadows.inner.color)
                    .opacity(appearance.shadows.inner.opacity),
                radius: appearance.shadows.inner.radius,
                x: appearance.shadows.inner.x,
                y: appearance.shadows.inner.y
            )
    }
}

// MARK: - View Extensions
extension View {
    func placeholder<Content: View>(
        when shouldShow: Bool,
        @ViewBuilder placeholder: () -> Content
    ) -> some View {
        ZStack(alignment: .leading) {
            placeholder().opacity(shouldShow ? 1 : 0)
            self
        }
    }
}