//
//  ContentView.swift
//  CatMatch
//
//  Created by Eduardo Andrade on 28/06/26.
//

import SwiftUI

// MARK: - ContentView

struct ContentView: View {

    // MARK: - Body

    var body: some View {
        NavigationStack {
            CatListView()
        }
    }
}

// MARK: - Preview

#Preview {
    ContentView()
}
