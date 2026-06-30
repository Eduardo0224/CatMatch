//
//  VoteHistoryTests+ViewModel.swift
//  CatMatchTests
//
//  Created by Eduardo Andrade on 29/06/26.
//

import Foundation
import Testing
import SwiftData
@testable import CatMatch

// MARK: - VoteHistoryTests + ViewModel

extension VoteHistoryTests {

    @Suite("VoteHistoryViewModel Tests")
    @MainActor
    struct ViewModelTests {

        // MARK: - Subject Under Test

        let modelContainer: ModelContainer
        let modelContext: ModelContext
        let sut: VoteHistoryViewModel

        // MARK: - Initializers

        init() throws {
            let config = ModelConfiguration(isStoredInMemoryOnly: true)
            let container = try ModelContainer(for: Vote.self, configurations: config)
            self.modelContainer = container
            self.modelContext = container.mainContext
            self.sut = VoteHistoryViewModel()
            self.sut.setModelContext(modelContext)

            // Seed sample votes
            seedVotes()
            sut.loadVotes()
        }

        // MARK: - Helpers

        private func seedVotes() {
            let likeVote = VoteHistoryTestData.sampleLikeVote()
            let dislikeVote = VoteHistoryTestData.sampleDislikeVote()
            let likeVote2 = VoteHistoryTestData.sampleLikeVote2()

            modelContext.insert(likeVote)
            modelContext.insert(dislikeVote)
            modelContext.insert(likeVote2)
            try? modelContext.save()
        }

        // MARK: - loadVotes Tests

        @Test("loadVotes fetches all votes from context sorted by date descending")
        func loadVotesAll() {
            #expect(sut.allVotes.count == 3)
            // Most recent first
            #expect(sut.allVotes[0].breedName == "Bengal")
            #expect(sut.allVotes[1].breedName == "Siamese")
            #expect(sut.allVotes[2].breedName == "Norwegian Forest Cat")
        }

        @Test("loadVotes returns empty when no votes in context")
        func loadVotesEmpty() throws {
            // Given: fresh context with no votes
            let config = ModelConfiguration(isStoredInMemoryOnly: true)
            let container = try ModelContainer(for: Vote.self, configurations: config)
            let emptyViewModel = VoteHistoryViewModel()
            emptyViewModel.setModelContext(container.mainContext)

            // When
            emptyViewModel.loadVotes()

            // Then
            #expect(emptyViewModel.allVotes.isEmpty)
            #expect(emptyViewModel.isEmpty)
        }

        // MARK: - filteredVoteIDs Tests

        @Test("filteredVoteIDs returns all IDs when filter is .all")
        func filteredVoteIDsAll() {
            // Given: filter is .all (default)
            #expect(sut.filterType == .all)

            // When
            let ids = sut.filteredVoteIDs

            // Then
            #expect(ids.count == 3)
        }

        @Test("filteredVoteIDs returns only like IDs when filter is .likes")
        func filteredVoteIDsLikes() {
            // When
            sut.setFilter(.likes)

            // Then
            #expect(sut.filteredVoteIDs.count == 2)
            let votes = sut.filteredVoteIDs.compactMap { sut.vote(for: $0) }
            #expect(votes.allSatisfy { $0.voteType == .like })
        }

        @Test("filteredVoteIDs returns only dislike IDs when filter is .dislikes")
        func filteredVoteIDsDislikes() {
            // When
            sut.setFilter(.dislikes)

            // Then
            #expect(sut.filteredVoteIDs.count == 1)
            let votes = sut.filteredVoteIDs.compactMap { sut.vote(for: $0) }
            #expect(votes.allSatisfy { $0.voteType == .dislike })
        }

        // MARK: - setFilter Tests

        @Test("setFilter updates filterType")
        func setFilterUpdatesType() {
            sut.setFilter(.likes)
            #expect(sut.filterType == .likes)

            sut.setFilter(.dislikes)
            #expect(sut.filterType == .dislikes)

            sut.setFilter(.all)
            #expect(sut.filterType == .all)
        }

        // MARK: - deleteVote Tests

        @Test("deleteVote removes vote and refreshes list")
        func deleteVote() {
            // Given
            #expect(sut.allVotes.count == 3)
            let voteToDelete = sut.allVotes.first!

            // When
            sut.deleteVote(id: voteToDelete.id)

            // Then
            #expect(sut.allVotes.count == 2)
            #expect(sut.vote(for: voteToDelete.id) == nil)
        }

        @Test("deleteVote with unknown ID does nothing")
        func deleteVoteUnknownID() {
            // Given
            let unknownID = UUID()

            // When
            sut.deleteVote(id: unknownID)

            // Then
            #expect(sut.allVotes.count == 3)
        }

        // MARK: - vote(for:) Tests

        @Test("vote(for:) returns correct vote by ID")
        func voteForID() {
            let targetID = sut.allVotes[1].id
            let vote = sut.vote(for: targetID)

            #expect(vote?.id == targetID)
            #expect(vote?.breedName == "Siamese")
        }

        @Test("vote(for:) returns nil for unknown ID")
        func voteForIDNil() {
            #expect(sut.vote(for: UUID()) == nil)
        }

        // MARK: - isEmpty Tests

        @Test("isEmpty returns false when votes exist")
        func isEmptyFalse() {
            #expect(sut.isEmpty == false)
        }

        @Test("isEmpty returns true when filtered to empty result")
        func isEmptyTrueAfterFilter() {
            // Delete all likes, then filter to likes
            for vote in sut.allVotes where vote.voteType == .like {
                sut.deleteVote(id: vote.id)
            }
            sut.setFilter(.likes)

            #expect(sut.isEmpty == true)
        }

        // MARK: - setModelContext Tests

        @Test("setModelContext stores context, loadVotes works")
        func setModelContext() throws {
            // Given: new ViewModel without context
            let vm = VoteHistoryViewModel()
            #expect(vm.allVotes.isEmpty)

            // When
            vm.setModelContext(modelContext)
            vm.loadVotes()

            // Then
            #expect(vm.allVotes.count == 3)
        }
    }
}
