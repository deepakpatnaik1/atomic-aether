//
//  ThemedContainer.swift
//  atomic-aether
//
//  Container that applies theme to its content
//  
//  ATOM 19: Theme System - UI container component
//
//  Atomic LEGO: UI component that uses ThemeService
//  Delete this and content still renders (just without theme)
//

import SwiftUI

struct ThemedContainer<Content: View>: View {
    @EnvironmentObject var themeService: ThemeService
    let content: () -> Content
    
    init(@ViewBuilder content: @escaping () -> Content) {
        self.content = content
    }
    
    var body: some View {
        ZStack {
            themeService.current.backgroundColor
                .ignoresSafeArea()
            
            content()
                .foregroundColor(themeService.current.primaryTextColor)
        }
    }
}