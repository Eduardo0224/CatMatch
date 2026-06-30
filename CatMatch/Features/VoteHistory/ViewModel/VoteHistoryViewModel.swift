//
//  VoteHistoryViewModel.swift
//  CatMatch
//
//  Created by Eduardo Andrade on 29/06/26.
//

import Foundation
import Observation
import SwiftData

// MARK: - VoteHistoryViewModel

@Observable
@MainActor
final class VoteHistoryViewModel {

    // MARK: - FilterType

    enum FilterType: String, CaseIterable {
        case all
        case likes
        case dislikes
    }

    // MARK: - Private Properties

    @ObservationIgnored
    private var modelContext: ModelContext?

    // MARK: - States

    private(set) var allVotes: [Vote] = []
    private(set) var filterType: FilterType = .all

    // MARK: - Computed Properties

    var latestVotesByBreed: [Vote] {
        var seen: [String: Vote] = [:]
        for vote in allVotes {
            if let existing = seen[vote.breedId], existing.date >= vote.date {
                continue
            }
            seen[vote.breedId] = vote
        }
        return seen.values.sorted { $0.date > $1.date }
    }

    var filteredVoteIDs: [Vote.ID] {
        switch filterType {
        case .all:
            return latestVotesByBreed.map(\.id)
        case .likes:
            return latestVotesByBreed.filter { $0.voteType == .like }.map(\.id)
        case .dislikes:
            return latestVotesByBreed.filter { $0.voteType == .dislike }.map(\.id)
        }
    }

    var isEmpty: Bool { filteredVoteIDs.isEmpty }

    // MARK: - Functions

    func setModelContext(_ context: ModelContext) {
        self.modelContext = context
    }

    func loadVotes() {
        guard let modelContext else { return }

        let descriptor = FetchDescriptor<Vote>(sortBy: [SortDescriptor(\.date, order: .reverse)])
        do {
            allVotes = try modelContext.fetch(descriptor)
        } catch {
            allVotes = []
        }
    }

    func setFilter(_ type: FilterType) {
        filterType = type
    }

    func deleteVote(id: Vote.ID) {
        guard let modelContext,
              let vote = allVotes.first(where: { $0.id == id }) else { return }

        modelContext.delete(vote)
        if modelContext.hasChanges {
            try? modelContext.save()
        }
        loadVotes()
    }

    func vote(for id: Vote.ID) -> Vote? {
        latestVotesByBreed.first { $0.id == id }
    }
}
