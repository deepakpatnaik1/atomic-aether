//
//  ScrollbackHistoryEvents.swift
//  atomic-aether
//
//  Events for scrollback history loading
//
//  ATOM 30: Scrollback History Loader - Event definitions
//
//  Atomic LEGO: Loading state events
//  Minimal events for history loading lifecycle
//

import Foundation

enum ScrollbackHistoryEvent: AetherEvent {
    case loadingStarted
    case messagesLoaded(count: Int, oldestDate: Date)
    case loadingFailed(Error)
    case noMoreHistory
    
    var source: String { "ScrollbackHistory" }
    
    var identifier: String {
        switch self {
        case .loadingStarted:
            return "scrollback.history.loading.started"
        case .messagesLoaded:
            return "scrollback.history.messages.loaded"
        case .loadingFailed:
            return "scrollback.history.loading.failed"
        case .noMoreHistory:
            return "scrollback.history.no.more"
        }
    }
}