//
//  ResponseSection.swift
//  atomic-aether
//
//  Response parsing data models
//
//  ATOM 23: Response Parser - Data models
//
//  Atomic LEGO: Pure data models for parsed response sections
//  Handles mixed inferability within responses
//

import Foundation

enum ResponseSection {
    case normal(String)
    case machineTrim(String)  // May contain [INFERABLE] markers mixed with content
    case empty               // Entire response was inferable
}

struct ParsedResponse {
    let normalContent: String
    let machineTrimContent: String  // Includes partial [INFERABLE] markers
    let hasNonInferableContent: Bool
}

enum ParsingMode {
    case waitingForMarker
    case parsingNormal
    case parsingMachineTrim
}