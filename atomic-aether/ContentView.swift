//
//  ContentView.swift
//  atomic-aether
//
//  Created by Deepak Patnaik on 29.07.25.
//
//  ATOM 1: Black Background - Basic app structure with dark theme
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
            Spacer()
            
            // Input Bar
            InputBarView()
        }
    }
}

#Preview {
    ContentView()
}
