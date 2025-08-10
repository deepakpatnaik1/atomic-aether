//
//  MarkdownMessageView.swift
//  atomic-aether
//
//  Reusable markdown message display component
//
//  ATOM 504: Markdown - UI component for rendering markdown
//
//  Atomic LEGO: Drop-in replacement for Text view with markdown support
//  Uses MarkdownUI library with configuration-driven styling
//

import SwiftUI
import MarkdownUI

struct MarkdownMessageView: View {
    let content: String
    let fontSize: Double?
    let opacity: Double?
    
    @EnvironmentObject var configBus: ConfigBus
    @State private var configuration: MarkdownConfiguration?
    
    init(
        content: String,
        fontSize: Double? = nil,
        opacity: Double? = nil
    ) {
        self.content = content
        self.fontSize = fontSize
        self.opacity = opacity
    }
    
    var body: some View {
        Markdown(content)
            .markdownTextStyle(\.text) {
                ForegroundColor(.white.opacity(effectiveOpacity))
                FontSize(effectiveFontSize)
            }
            .markdownTextStyle(\.strong) {
                FontWeight(.bold)
                ForegroundColor(.white.opacity(configuration?.text.boldOpacity ?? 0.95))
            }
            .markdownTextStyle(\.emphasis) {
                FontStyle(.italic)
                ForegroundColor(.white.opacity(configuration?.text.italicOpacity ?? 0.85))
            }
            .markdownTextStyle(\.link) {
                ForegroundColor(MarkdownConfiguration.color(from: configuration?.links.color ?? "cyan"))
                UnderlineStyle(configuration?.links.underline ?? true ? .single : .none)
            }
            .markdownTextStyle(\.code) {
                FontFamilyVariant(.monospaced)
                FontSize(configuration?.code.inlineFontSize ?? 12)
                BackgroundColor(Color.white.opacity(configuration?.code.inlineBackgroundOpacity ?? 0.1))
            }
            .markdownBlockStyle(\.heading1) { configuration in
                configuration.label
                    .markdownTextStyle {
                        FontSize(self.configuration?.headings.h1.fontSize ?? 24)
                        FontWeight(.bold)
                        ForegroundColor(.white.opacity(self.configuration?.headings.h1.opacity ?? 0.95))
                    }
                    .padding(.top, self.configuration?.headings.h1.topPadding ?? 16)
                    .padding(.bottom, self.configuration?.headings.h1.bottomPadding ?? 8)
            }
            .markdownBlockStyle(\.heading2) { configuration in
                configuration.label
                    .markdownTextStyle {
                        FontSize(self.configuration?.headings.h2.fontSize ?? 20)
                        FontWeight(.semibold)
                        ForegroundColor(.white.opacity(self.configuration?.headings.h2.opacity ?? 0.9))
                    }
                    .padding(.top, self.configuration?.headings.h2.topPadding ?? 12)
                    .padding(.bottom, self.configuration?.headings.h2.bottomPadding ?? 6)
            }
            .markdownBlockStyle(\.heading3) { configuration in
                configuration.label
                    .markdownTextStyle {
                        FontSize(self.configuration?.headings.h3.fontSize ?? 17)
                        FontWeight(.medium)
                        ForegroundColor(.white.opacity(self.configuration?.headings.h3.opacity ?? 0.9))
                    }
                    .padding(.top, self.configuration?.headings.h3.topPadding ?? 8)
                    .padding(.bottom, self.configuration?.headings.h3.bottomPadding ?? 4)
            }
            .textSelection(.enabled)
            .frame(maxWidth: .infinity, alignment: .leading)
            .fixedSize(horizontal: false, vertical: true)
            .onAppear {
                loadConfiguration()
            }
    }
    
    private func loadConfiguration() {
        // Load configuration
        if let config = configBus.load("MarkdownAppearance", as: MarkdownConfiguration.self) {
            self.configuration = config
            
            // Configuration loaded, theme is already set to gitHub
        }
    }
    
    // Computed properties for defaults
    private var effectiveFontSize: Double {
        fontSize ?? configuration?.defaults.fontSize ?? 13
    }
    
    private var effectiveOpacity: Double {
        opacity ?? configuration?.defaults.opacity ?? 0.9
    }
}


// MARK: - Preview Support

#if DEBUG
struct MarkdownMessageView_Previews: PreviewProvider {
    static let sampleMarkdown = """
    # Heading 1
    ## Heading 2
    ### Heading 3
    
    This is a paragraph with **bold text** and *italic text* and ***bold italic***.
    
    Here's a bullet list:
    - First item
    - Second item with **bold**
    - Third item with *italic*
    
    And a numbered list:
    1. First numbered item
    2. Second numbered item
    3. Third numbered item
    
    > This is a blockquote
    > with multiple lines
    
    Here's some `inline code` and a code block:
    
    ```swift
    func hello() {
        print("Hello, World!")
    }
    ```
    
    And finally, a [link to Apple](https://apple.com).
    """
    
    static var previews: some View {
        VStack {
            MarkdownMessageView(content: sampleMarkdown)
                .padding()
                .background(Color.black)
                .preferredColorScheme(.dark)
        }
        .environmentObject(ConfigBus(eventBus: EventBus()))
    }
}
#endif