//
//  ErrorToast.swift
//  atomic-aether
//
//  Toast UI for displaying errors
//
//  ATOM 11: ErrorBus - Error display component
//
//  Atomic LEGO: Non-intrusive error display
//  Shows current error with appropriate styling
//

import SwiftUI

struct ErrorToast: View {
    @EnvironmentObject var errorBus: ErrorBus
    @State private var isShowing = false
    
    var body: some View {
        VStack {
            if let context = errorBus.currentError {
                toastView(for: context)
                    .transition(.asymmetric(
                        insertion: .move(edge: .top).combined(with: .opacity),
                        removal: .move(edge: .top).combined(with: .opacity)
                    ))
                    .zIndex(999)
                    .onAppear {
                        withAnimation(.easeOut(duration: 0.3)) {
                            isShowing = true
                        }
                    }
                    .onDisappear {
                        isShowing = false
                    }
            }
            
            Spacer()
        }
        .animation(.easeInOut(duration: 0.3), value: errorBus.currentError?.id)
    }
    
    @ViewBuilder
    private func toastView(for context: ErrorContext) -> some View {
        HStack(spacing: 12) {
            // Icon
            Image(systemName: context.severity.icon)
                .font(.title3)
                .foregroundColor(.white)
            
            // Message
            VStack(alignment: .leading, spacing: 4) {
                Text(context.message)
                    .font(.system(.body, design: .rounded))
                    .fontWeight(.medium)
                    .foregroundColor(.white)
                    .lineLimit(2)
                
                if let suggestion = context.recoverySuggestion {
                    Text(suggestion)
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.8))
                        .lineLimit(1)
                }
            }
            
            Spacer()
            
            // Dismiss button
            Button(action: {
                withAnimation(.easeIn(duration: 0.2)) {
                    errorBus.dismiss()
                }
            }) {
                Image(systemName: "xmark.circle.fill")
                    .font(.title3)
                    .foregroundColor(.white.opacity(0.8))
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(context.severity.color)
                .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 5)
        )
        .frame(maxWidth: 400)
        .padding(.horizontal)
        .padding(.top, 50) // Account for window controls
    }
}

// MARK: - Toast Modifier

struct ErrorToastModifier: ViewModifier {
    func body(content: Content) -> some View {
        ZStack {
            content
            ErrorToast()
        }
    }
}

extension View {
    func errorToast() -> some View {
        modifier(ErrorToastModifier())
    }
}