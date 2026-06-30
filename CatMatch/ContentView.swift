//
//  ContentView.swift
//  CatMatch
//
//  Created by Eduardo Andrade on 28/06/26.
//

import SwiftUI

// MARK: - ContentView

struct ContentView: View {

    // MARK: - States

    @State private var breedStore = BreedStore()

    // MARK: - Body

    var body: some View {
        TabView {
            NavigationStack {
                CatListView(breedStore: breedStore)
            }
            .tabItem {
                Label("Breeds", systemImage: "pawprint")
            }

            NavigationStack {
                VotingView(breedStore: breedStore)
            }
            .tabItem {
                Label("Vote", systemImage: "heart")
            }
        }
    }
}

// MARK: - Preview

#Preview {
    ContentView()
}
