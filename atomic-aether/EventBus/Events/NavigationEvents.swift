//
//  NavigationEvents.swift
//  atomic-aether
//
//  Events related to UI navigation
//
//  ATOM 1: EventBus - Navigation event definitions
//
//  ATOMIC LEGO: Pure navigation event definitions
//  - Turn mode, scrolling, focus changes
//  - UI state transitions
//

import Foundation

// MARK: - Navigation Events

enum NavigationEvent: NavigationEventType {
    case turnModeEntered(source: String)
    case turnModeExited(source: String)
    case navigatedToTurn(turnId: UUID, index: Int, source: String)
    case scrolledToPosition(position: CGFloat, source: String)
    case scrolledToMessage(messageId: UUID, source: String)
    case focusRequested(component: FocusTarget, source: String)
    case viewAppeared(view: String, source: String)
    case viewDisappeared(view: String, source: String)
    
    // MARK: - AetherEvent Conformance
    
    var source: String {
        switch self {
        case .turnModeEntered(let source),
             .turnModeExited(let source),
             .navigatedToTurn(_, _, let source),
             .scrolledToPosition(_, let source),
             .scrolledToMessage(_, let source),
             .focusRequested(_, let source),
             .viewAppeared(_, let source),
             .viewDisappeared(_, let source):
            return source
        }
    }
}

// MARK: - Navigation Data Types

enum FocusTarget {
    case inputBar
    case scrollback
    case modelPicker
    case custom(String)
}

struct TurnNavigationData {
    let turnId: UUID
    let index: Int
    let totalTurns: Int
    let direction: NavigationDirection
    
    enum NavigationDirection {
        case up
        case down
        case jump(to: Int)
    }
}