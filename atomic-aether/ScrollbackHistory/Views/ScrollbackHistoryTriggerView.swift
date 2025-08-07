//
//  ScrollbackHistoryTriggerView.swift
//  atomic-aether
//
//  UI trigger for loading historical messages
//
//  ATOM 30: Scrollback History Loader - Trigger view
//
//  Atomic LEGO: Button to load more messages
//  Appears at top of scrollback when enabled
//

import SwiftUI

struct ScrollbackHistoryTriggerView: View {
    @EnvironmentObject var historyLoader: ScrollbackHistoryLoaderService
    @EnvironmentObject var themeService: ThemeService
    
    // Configuration
    private let configuration: ScrollbackHistoryConfiguration
    
    init(configuration: ScrollbackHistoryConfiguration = .default) {
        self.configuration = configuration
    }
    
    var body: some View {
        VStack(spacing: 12) {
            if historyLoader.isLoading && configuration.showLoadingIndicator {
                // Loading state
                HStack(spacing: 8) {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                        .scaleEffect(0.8)
                    
                    Text(configuration.loadingText)
                        .font(.system(size: configuration.buttonStyle.fontSize))
                        .foregroundColor(themeService.current.secondaryTextColor)
                }
                .padding(configuration.buttonStyle.padding)
                
            } else if !historyLoader.hasMoreHistory {
                // No more history
                Text(configuration.noMoreHistoryText)
                    .font(.system(size: configuration.buttonStyle.fontSize))
                    .foregroundColor(themeService.current.secondaryTextColor.opacity(0.5))
                    .padding(configuration.buttonStyle.padding)
                
            } else {
                // Load more button
                Button(action: {
                    Task {
                        await historyLoader.loadMoreHistory()
                    }
                }) {
                    Text(configuration.loadMoreButtonText)
                        .font(.system(size: configuration.buttonStyle.fontSize))
                        .foregroundColor(colorFromString(configuration.buttonStyle.textColor))
                        .padding(.horizontal, configuration.buttonStyle.padding * 2)
                        .padding(.vertical, configuration.buttonStyle.padding)
                        .background(
                            RoundedRectangle(cornerRadius: configuration.buttonStyle.cornerRadius)
                                .fill(colorFromString(configuration.buttonStyle.backgroundColor).opacity(configuration.buttonStyle.opacity))
                        )
                }
                .buttonStyle(PlainButtonStyle())
                .disabled(historyLoader.isLoading)
                .onAppear {
                    // Auto-load when trigger appears if enabled
                    if configuration.autoLoadOnScroll && 
                       !historyLoader.isLoading && 
                       historyLoader.hasMoreHistory {
                        Task {
                            await historyLoader.loadMoreHistory()
                        }
                    }
                }
                
                // Error state
                if let error = historyLoader.loadError {
                    Text("Error: \(error.localizedDescription)")
                        .font(.system(size: 12))
                        .foregroundColor(.red)
                        .padding(.horizontal)
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .animation(.easeInOut(duration: 0.2), value: historyLoader.isLoading)
    }
    
    // Helper to convert string color names to SwiftUI colors
    private func colorFromString(_ colorName: String) -> Color {
        switch colorName.lowercased() {
        case "white": return .white
        case "black": return .black
        case "gray", "grey": return .gray
        case "red": return .red
        case "green": return .green
        case "blue": return .blue
        case "orange": return .orange
        case "yellow": return .yellow
        case "pink": return .pink
        case "purple": return .purple
        case "primary": return .primary
        case "secondary": return .secondary
        default: return .gray
        }
    }
}

// MARK: - Preview

struct ScrollbackHistoryTriggerView_Previews: PreviewProvider {
    static var previews: some View {
        ScrollbackHistoryTriggerView()
            .environmentObject(ScrollbackHistoryLoaderService())
            .environmentObject(ThemeService())
            .frame(width: 700)
            .background(Color.black)
    }
}