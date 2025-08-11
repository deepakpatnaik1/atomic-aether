//
//  InputBarView.swift
//  atomic-aether
//
//  Pure visual input bar component with uniform padding
//
//  ATOM 301: Input Bar - Text input system with glassmorphic UI
//  Includes multiline support and slash command detection
//
//  Atomic LEGO: UI-only, no behavior
//  Just appearance as defined in configuration
//

import SwiftUI
import Combine

struct InputBarView: View {
    @StateObject private var appearanceService = InputBarAppearanceService()
    @StateObject private var slashCommandDetector = SlashCommandDetector()
    @StateObject private var keyboardService = KeyboardService()
    @EnvironmentObject var configBus: ConfigBus
    @EnvironmentObject var eventBus: EventBus
    @EnvironmentObject var stateBus: StateBus
    @EnvironmentObject var conversationOrchestrator: ConversationOrchestrator
    @EnvironmentObject var modelDisplayService: ModelDisplayService
    @EnvironmentObject var modelPickerService: ModelPickerService
    @EnvironmentObject var personaStateService: PersonaStateService
    @FocusState private var isTextFieldFocused: Bool
    @State private var text = ""
    @State private var cancellables = Set<AnyCancellable>()
    @State private var contentWidth: CGFloat = 700 // Default fallback
    
    var body: some View {
        Group {
            if let appearance = appearanceService.appearance {
                inputBar(appearance: appearance)
                    .frame(width: contentWidth)
                    .padding(.bottom, appearance.dimensions.bottomMargin)
            } else {
                // Loading state - appearance will be loaded in onAppear
                ProgressView()
                    .padding()
            }
        }
        .onAppear {
            // Setup services with buses
            appearanceService.setupWithConfigBus(configBus)
            slashCommandDetector.setupWithBuses(configBus, eventBus)
            keyboardService.setupWithConfigBus(configBus)
            
            // Subscribe to text insertion events
            eventBus.subscribe(to: InputEvent.self) { event in
                if case .insertText(let newText, _) = event {
                    text = newText
                    isTextFieldFocused = true
                }
            }
            .store(in: &cancellables)
            
            // Subscribe to width changes from ContentView
            if let width = stateBus.get(StateKey.contentWidth) {
                contentWidth = width
            }
            
            eventBus.subscribe(to: StateChangedEvent.self) { event in
                if event.key == StateKey.contentWidth.name,
                   let width = event.newValue as? CGFloat {
                    contentWidth = width
                }
            }
            .store(in: &cancellables)
        }
    }
    
    @ViewBuilder
    private func inputBar(appearance: InputBarAppearance) -> some View {
        VStack(spacing: appearance.padding.uniform) {
            // Text editor for multiline support
            if appearance.multiline.enabled {
                textEditor(appearance: appearance)
            } else {
                textField(appearance: appearance)
            }
            
            // Controls row
            HStack(spacing: appearance.controls.spacing) {
                Image(systemName: appearance.controls.plusButton.iconName)
                    .font(.system(size: appearance.controls.plusButton.size, weight: .medium))
                    .foregroundColor(plusButtonColor(appearance).opacity(appearance.controls.plusButton.opacity))
                
                ModelPickerView(
                    modelPickerService: modelPickerService,
                    modelDisplayService: modelDisplayService,
                    fontSize: appearance.controls.modelPicker.fontSize,
                    opacity: appearance.controls.modelPicker.opacity,
                    color: modelPickerColor(appearance),
                    focusState: $isTextFieldFocused
                )
                .fixedSize()
                
                PersonaPickerView(
                    fontSize: appearance.controls.modelPicker.fontSize,
                    opacity: appearance.controls.modelPicker.opacity,
                    color: modelPickerColor(appearance),
                    focusState: $isTextFieldFocused
                )
                .fixedSize()
                
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
        .background(
            glassmorphicBackground(appearance: appearance)
        )
        .preferredColorScheme(.dark)
        .background(
            // Invisible button for Cmd+Enter shortcut
            Button("") { handleSubmit() }
                .keyboardShortcut(.return, modifiers: .command)
                .opacity(0)
        )
    }
    
    @ViewBuilder
    private func textEditor(appearance: InputBarAppearance) -> some View {
        // Calculate height based on slash command
        let maxLines = slashCommandDetector.activeCommand?.expandToLines ?? appearance.multiline.maxLines
        
        ZStack(alignment: .topLeading) {
            TextEditor(text: $text)
                .font(.system(size: appearance.textField.fontSize))
                .foregroundColor(InputBarAppearance.color(from: appearance.textField.textColor))
                .scrollContentBackground(.hidden)
                .background(Color.clear)
                .focused($isTextFieldFocused)
                .frame(
                    minHeight: slashCommandDetector.isExpanded 
                        ? appearance.multiline.lineHeight * Double(maxLines)
                        : appearance.multiline.lineHeight,
                    maxHeight: appearance.multiline.lineHeight * Double(maxLines)
                )
                .fixedSize(horizontal: false, vertical: true)
                .onAppear {
                    isTextFieldFocused = true
                }
            
        }
        .onChange(of: text) { oldValue, newValue in
                // Detect slash commands for expansion
                let shouldClear = slashCommandDetector.handleTextChange(newValue)
                if shouldClear {
                    // Clear text after command detection
                    text = ""
                }
                // Check if first word is a persona name for real-time switching
                checkForPersonaSwitch(newValue)
            }
            .onKeyPress(.escape) {
                // Check collapse conditions
                if slashCommandDetector.shouldAllowCollapse(text: text) {
                    slashCommandDetector.collapse()
                    return .handled
                }
                return .ignored
            }
            .smartReturnKey(keyboardService: keyboardService, onSubmit: handleSubmit)
    }
    
    @ViewBuilder
    private func textField(appearance: InputBarAppearance) -> some View {
        TextField("", text: $text)
            .textFieldStyle(.plain)
            .font(.system(size: appearance.textField.fontSize))
            .foregroundColor(InputBarAppearance.color(from: appearance.textField.textColor))
            .focused($isTextFieldFocused)
            .frame(minHeight: appearance.dimensions.textFieldMinHeight)
            .onAppear {
                isTextFieldFocused = true
            }
            .onChange(of: text) {
                let newValue = text
                // Detect slash commands for expansion
                let shouldClear = slashCommandDetector.handleTextChange(newValue)
                if shouldClear {
                    // Clear text after command detection
                    text = ""
                }
                // Check if first word is a persona name for real-time switching
                checkForPersonaSwitch(newValue)
            }
            .onKeyPress(.escape) {
                // Check collapse conditions
                if slashCommandDetector.shouldAllowCollapse(text: text) {
                    slashCommandDetector.collapse()
                    return .handled
                }
                return .ignored
            }
            .smartReturnKey(keyboardService: keyboardService, onSubmit: handleSubmit)
    }
    
    private func handleSubmit() {
        guard !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        guard !conversationOrchestrator.isProcessing else { return }
        
        let message = text
        text = "" // Clear immediately for responsiveness
        
        // Process message asynchronously
        Task {
            await conversationOrchestrator.processMessage(message)
        }
    }
    
    private func checkForPersonaSwitch(_ text: String) {
        // Extract first word
        let trimmed = text.trimmingCharacters(in: .whitespaces)
        let words = trimmed.split(separator: " ", maxSplits: 1)
        
        if let firstWord = words.first {
            let potentialPersona = String(firstWord).lowercased()
            
            // Check if it's a valid persona
            if personaStateService.configuration.isValidPersona(potentialPersona) {
                // Switch persona immediately for UI update
                personaStateService.switchToPersona(potentialPersona)
            }
        }
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
    
    private func plusButtonColor(_ appearance: InputBarAppearance) -> Color {
        if let colorString = appearance.controls.plusButton.color {
            return InputBarAppearance.color(from: colorString)
        }
        return .white
    }
    
    private func modelPickerColor(_ appearance: InputBarAppearance) -> Color? {
        if let colorString = appearance.controls.modelPicker.color {
            return InputBarAppearance.color(from: colorString)
        }
        return nil
    }
}

