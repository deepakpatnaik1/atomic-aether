//
//  KeyboardWire.swift
//  atomic-aether
//
//  Wire for KeyboardBehavior atom
//
//  ATOM 16: Smart Enter Key - Wire
//
//  Atomic LEGO: Connection point for keyboard behavior
//  Documents how this atom integrates with the app
//

/*
 INTEGRATION POINTS:
 
 1. InputBarView:
    - Added @StateObject keyboardService
    - Wired through ConfigBus in onAppear
    - Replaced .onSubmit with .onKeyPress(.return)
 
 2. Configuration:
    - Loads from KeyboardBehavior.json
    - Supports both shift and option for newlines
 
 3. Behavior:
    - Enter → Submit message
    - Shift+Enter → New line (ChatGPT style)
    - Option+Enter → New line (Claude style)
 
 REMOVAL:
 To remove this atom:
 1. Delete KeyboardBehavior folder
 2. Remove keyboardService from InputBarView
 3. Replace .onKeyPress(.return) with .onSubmit
 4. Delete KeyboardBehavior.json
 */