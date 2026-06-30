//
//  ContentView.swift
//  CatMatch
//
//  Created by Eduardo Andrade on 28/06/26.
//

import SwiftUI
import SwiftData
import CatUI

// MARK: - ContentView

struct ContentView: View {

    // MARK: - States

    @State private var breedStore = BreedStore()
    @State private var historyViewModel = VoteHistoryViewModel()
    @Environment(\.modelContext) private var modelContext

    // MARK: - Body

    var body: some View {
        TabView {
            Tab(L10n.CatList.title, systemImage: "pawprint") {
                NavigationStack {
                    CatListView(breedStore: breedStore)
                }
            }

            Tab(L10n.Voting.title, systemImage: "heart") {
                NavigationStack {
                    VotingView(breedStore: breedStore)
                }
            }

            Tab(L10n.VoteHistory.title, systemImage: "clock.arrow.circlepath") {
                VoteHistoryRepresentable(viewModel: historyViewModel)
                    .ignoresSafeArea(edges: .all)
            }
        }
        .tint(Color.catAccent)
        .task {
            historyViewModel.setModelContext(modelContext)
            historyViewModel.loadVotes()
        }
    }
}

// MARK: - Preview

#Preview {
    ContentView()
}
