//
//  ResponseParserService.swift
//  atomic-aether
//
//  Parses streaming LLM responses with two-part format
//
//  ATOM 22: Response Parser - Core service
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
        // Don't accumulate or process anything until we see the first marker
        if currentMode == .waitingForMarker {
            currentBuffer += token
            checkForSectionMarkers()
            return
        }
        
        // In parsing modes, we need to buffer to detect the next marker
        currentBuffer += token
        
        // Check for section transitions
        checkForSectionMarkers()
        
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
                // Safely remove everything up to and including the marker
                if normalRange.upperBound < currentBuffer.endIndex {
                    currentBuffer = String(currentBuffer[normalRange.upperBound...])
                } else {
                    currentBuffer = ""
                }
                normalContent = ""
                // Now stream any content that's in the buffer after the marker
                streamBufferedContent()
            }
        }
        
        // Check for machine trim marker
        if let trimRange = currentBuffer.range(of: configuration.machineTrimMarker) {
            if currentMode == .parsingNormal {
                // Save and publish any remaining normal content before the marker
                let beforeMarker = String(currentBuffer[..<trimRange.lowerBound])
                if !beforeMarker.isEmpty {
                    eventBus?.publish(ResponseParserEvent.normalToken(beforeMarker))
                    normalContent += beforeMarker
                }
                
                // Transition to machine trim mode
                currentMode = .parsingMachineTrim
                // Safely remove everything up to and including the marker
                if trimRange.upperBound < currentBuffer.endIndex {
                    currentBuffer = String(currentBuffer[trimRange.upperBound...])
                } else {
                    currentBuffer = ""
                }
                machineTrimContent = ""
                
                // Publish complete normal response
                let cleaned = normalContent.trimmingCharacters(in: .whitespacesAndNewlines)
                eventBus?.publish(ResponseParserEvent.normalResponseComplete(content: cleaned))
            }
        } else if currentMode == .parsingNormal {
            // No machine trim marker found yet, stream available content
            streamBufferedContent()
        }
    }
    
    private func streamBufferedContent() {
        guard currentMode == .parsingNormal else { return }
        
        // Keep some buffer to ensure we don't miss markers
        let keepBack = max(configuration.normalMarker.count, configuration.machineTrimMarker.count)
        
        if currentBuffer.count > keepBack {
            let streamEndIndex = currentBuffer.index(currentBuffer.endIndex, offsetBy: -keepBack)
            let contentToStream = String(currentBuffer[..<streamEndIndex])
            
            if !contentToStream.isEmpty {
                eventBus?.publish(ResponseParserEvent.normalToken(contentToStream))
                normalContent += contentToStream
                currentBuffer = String(currentBuffer[streamEndIndex...])
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
            // First publish any remaining buffer content
            if !currentBuffer.isEmpty {
                eventBus?.publish(ResponseParserEvent.normalToken(currentBuffer))
                normalContent += currentBuffer
            }
            // Complete normal response without machine trim
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