//
//  VotingViewModel.swift
//  CatMatch
//
//  Created by Eduardo Andrade on 29/06/26.
//

import Foundation
import Observation
import SwiftData
import SwiftUI

// MARK: - VotingViewModel

@Observable
final class VotingViewModel: VotingViewModelProtocol {

    // MARK: - Private Properties

    @ObservationIgnored
    private let breedStore: any BreedStoreProtocol

    @ObservationIgnored
    private var modelContext: ModelContext?

    // MARK: - States

    private(set) var breeds: [CatBreed] = []
    private(set) var breedImages: [String: CatImage] = [:]
    var isLoading: Bool { breedStore.isLoading }
    private(set) var errorMessage: String?
    private(set) var isOutOfBreeds = false

    /// ID of the breed currently centered in the horizontal ScrollView.
    var currentBreedID: String?

    // MARK: - Initializers

    init(breedStore: any BreedStoreProtocol) {
        self.breedStore = breedStore
    }

    // MARK: - Functions

    var currentBreed: CatBreed? {
        guard let id = currentBreedID else { return nil }
        return breeds.first { $0.id == id }
    }

    func imageURL(for breedID: String) -> URL? {
        breedImages[breedID]?.url
    }

    func setModelContext(_ context: ModelContext) {
        self.modelContext = context
    }

    func loadData() async {
        await breedStore.loadIfNeeded()
        errorMessage = breedStore.errorMessage
        breeds = breedStore.breeds
        breedImages = breedStore.breedImages
        isOutOfBreeds = breeds.isEmpty
        if !isOutOfBreeds, currentBreedID == nil {
            currentBreedID = breeds.first?.id
        }
    }

    func likeBreed() {
        guard let breed = currentBreed else { return }
        saveVote(breed: breed, image: breedImages[breed.id], type: .like)
        advanceFromCurrent()
    }

    func dislikeBreed() {
        guard let breed = currentBreed else { return }
        saveVote(breed: breed, image: breedImages[breed.id], type: .dislike)
        advanceFromCurrent()
    }

    func retry() {
        breedStore.retry()
    }

    // MARK: - Private Functions

    /// Persist or update a vote for the given breed.
    /// Only one vote per breed — changing from like to dislike updates the record.
    private func saveVote(breed: CatBreed, image: CatImage?, type: Vote.VoteType) {
        guard let modelContext else { return }

        let breedId = breed.id
        var descriptor = FetchDescriptor<Vote>(predicate: #Predicate { $0.breedId == breedId })
        descriptor.fetchLimit = 1

        if let existing = try? modelContext.fetch(descriptor).first {
            // Update existing vote for this breed
            existing.voteType = type
            existing.date = Date()
            if let url = image?.url {
                existing.imageUrl = url
            }
        } else {
            // Create new vote
            let vote = Vote(
                breedId: breedId,
                breedName: breed.name,
                imageUrl: image?.url,
                voteType: type,
                date: Date()
            )
            modelContext.insert(vote)
        }

        if modelContext.hasChanges {
            try? modelContext.save()
        }
    }

    private func advanceFromCurrent() {
        guard let currentID = currentBreedID,
              let index = breeds.firstIndex(where: { $0.id == currentID }) else { return }
        let nextIndex = index + 1
        guard nextIndex < breeds.count else {
            isOutOfBreeds = true
            return
        }
        withAnimation(.snappy) {
            currentBreedID = breeds[nextIndex].id
        }
    }
}
