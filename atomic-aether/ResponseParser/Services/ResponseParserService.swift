//
//  ResponseParserService.swift
//  atomic-aether
//
//  Parses streaming LLM responses with two-part format
//
//  ATOM 23: Response Parser - Core service
//
//  Atomic LEGO: Detects section markers and routes content
//  Handles mixed inferability within machine trim sections
//

import Foundation

@MainActor
class ResponseParserService: ObservableObject {
    // Configuration
    private var configuration: ResponseParserConfiguration = .default
    private var configBus: ConfigBus?
    private var eventBus: EventBus?
    
    // Parsing state
    private var currentMode: ParsingMode = .waitingForMarker
    private var currentBuffer = ""
    private var normalContent = ""
    private var machineTrimContent = ""
    
    func setup(configBus: ConfigBus, eventBus: EventBus) {
        self.configBus = configBus
        self.eventBus = eventBus
        loadConfiguration()
    }
    
    private func loadConfiguration() {
        if let config = configBus?.load("ResponseParser", as: ResponseParserConfiguration.self) {
            self.configuration = config
        }
    }
    
    func parseStreamingToken(_ token: String) {
        currentBuffer += token
        
        // Check for section transitions
        checkForSectionMarkers()
        
        // In normal mode, stream tokens immediately to display
        if currentMode == .parsingNormal {
            eventBus?.publish(ResponseParserEvent.normalToken(token))
        }
        
        // Trim buffer if it gets too large
        if currentBuffer.count > configuration.bufferSize {
            trimBuffer()
        }
    }
    
    private func checkForSectionMarkers() {
        // Check for normal response marker
        if let normalRange = currentBuffer.range(of: configuration.normalMarker) {
            if currentMode == .waitingForMarker {
                currentMode = .parsingNormal
                currentBuffer.removeSubrange(...normalRange.upperBound)
                normalContent = ""
            }
        }
        
        // Check for machine trim marker
        if let trimRange = currentBuffer.range(of: configuration.machineTrimMarker) {
            if currentMode == .parsingNormal {
                // Save accumulated normal content
                let beforeMarker = currentBuffer[..<trimRange.lowerBound]
                normalContent += beforeMarker
                
                // Transition to machine trim mode
                currentMode = .parsingMachineTrim
                currentBuffer.removeSubrange(...trimRange.upperBound)
                machineTrimContent = ""
                
                // Publish complete normal response
                let cleaned = normalContent.trimmingCharacters(in: .whitespacesAndNewlines)
                eventBus?.publish(ResponseParserEvent.normalResponseComplete(content: cleaned))
            }
        }
    }
    
    private func trimBuffer() {
        // Keep only the last part of buffer to ensure we don't miss markers
        let keepLength = configuration.bufferSize / 2
        if currentBuffer.count > keepLength {
            let startIndex = currentBuffer.index(currentBuffer.endIndex, offsetBy: -keepLength)
            currentBuffer = String(currentBuffer[startIndex...])
        }
    }
    
    func completeResponse() {
        // Handle any remaining content
        switch currentMode {
        case .parsingNormal:
            // Complete normal response without machine trim
            normalContent += currentBuffer
            let cleaned = normalContent.trimmingCharacters(in: .whitespacesAndNewlines)
            if !cleaned.isEmpty {
                eventBus?.publish(ResponseParserEvent.normalResponseComplete(content: cleaned))
            }
            
        case .parsingMachineTrim:
            // Complete machine trim section
            machineTrimContent += currentBuffer
            let trimmed = machineTrimContent.trimmingCharacters(in: .whitespacesAndNewlines)
            
            if trimmed == configuration.inferableOnlyMarker {
                // Entire response was inferable
                eventBus?.publish(ResponseParserEvent.fullyInferableResponse)
            } else if containsNonInferableContent(trimmed) {
                // Contains mixed content
                eventBus?.publish(ResponseParserEvent.machineTrimComplete(content: trimmed))
            } else {
                // Empty or only whitespace
                eventBus?.publish(ResponseParserEvent.fullyInferableResponse)
            }
            
        case .waitingForMarker:
            // No structured response detected - treat as normal
            let content = currentBuffer.trimmingCharacters(in: .whitespacesAndNewlines)
            if !content.isEmpty {
                eventBus?.publish(ResponseParserEvent.normalResponseComplete(content: content))
            }
        }
        
        reset()
    }
    
    private func containsNonInferableContent(_ content: String) -> Bool {
        // Check if content has more than just [INFERABLE] markers
        let withoutInferable = content
            .replacingOccurrences(of: configuration.inferableMarker, with: "")
            .trimmingCharacters(in: CharacterSet(charactersIn: "[]- "))
            .trimmingCharacters(in: .whitespacesAndNewlines)
        
        return !withoutInferable.isEmpty
    }
    
    func reset() {
        currentMode = .waitingForMarker
        currentBuffer = ""
        normalContent = ""
        machineTrimContent = ""
    }
}