//
//  VotingTests+ViewModel.swift
//  CatMatchTests
//
//  Created by Eduardo Andrade on 29/06/26.
//

import Foundation
import Testing
import SwiftData
@testable import CatMatch

// MARK: - VotingTests + ViewModel

extension VotingTests {

    @Suite("VotingViewModel Tests")
    @MainActor
    struct ViewModelTests {

        // MARK: - Subject Under Test

        let spyNetwork: SpyNetworkService
        let breedStore: BreedStore
        let sut: VotingViewModel

        // MARK: - Initializers

        init() {
            self.spyNetwork = SpyNetworkService()
            self.breedStore = BreedStore(network: spyNetwork)
            self.sut = VotingViewModel(breedStore: breedStore)
        }

        // MARK: - Helpers

        func stubBreedsWithImages() async {
            await spyNetwork.setSuccess(VotingTestData.threeBreeds, for: API.Endpoints.breeds)
            await spyNetwork.setSuccess(VotingTestData.bengalImage, for: API.Endpoints.imageByID("beng_ref_001"))
            await spyNetwork.setSuccess(VotingTestData.bengalImage, for: API.Endpoints.imageByID("siam_ref_002"))
        }

        // MARK: - loadData Tests

        @Test("loadData sets breeds and images from breedStore")
        func loadDataSuccess() async {
            await stubBreedsWithImages()

            await sut.loadData()

            #expect(sut.breeds.count == 3)
            #expect(sut.breedImages.count == 2)
            #expect(sut.currentBreedID == "beng")
            #expect(sut.isOutOfBreeds == false)
        }

        @Test("loadData sets isOutOfBreeds when store is empty")
        func loadDataEmpty() async {
            await spyNetwork.setSuccess([] as [CatBreed], for: API.Endpoints.breeds)

            await sut.loadData()

            #expect(sut.breeds.isEmpty)
            #expect(sut.isOutOfBreeds == true)
        }

        @Test("loadData sets errorMessage on network error")
        func loadDataError() async {
            await spyNetwork.setFailure(NetworkError.rateLimited, for: API.Endpoints.breeds)

            await sut.loadData()

            #expect(sut.breeds.isEmpty)
            #expect(sut.errorMessage != nil)
        }

        @Test("loadData does not re-enter — breedStore guards idempotently")
        func loadDataNoReentry() async {
            await stubBreedsWithImages()

            async let first = sut.loadData()
            async let second = sut.loadData()
            _ = await (first, second)

            let breedFetchCount = await spyNetwork.endpoints.filter { $0 == API.Endpoints.breeds }.count
            #expect(breedFetchCount == 1)
        }

        // MARK: - likeBreed Tests

        @Test("likeBreed advances currentBreedID to next breed")
        func likeBreedAdvances() async {
            await stubBreedsWithImages()
            await sut.loadData()
            #expect(sut.currentBreedID == "beng")

            sut.likeBreed()
            #expect(sut.currentBreedID == "siam")

            sut.likeBreed()
            #expect(sut.currentBreedID == "norf")

            sut.likeBreed()
            #expect(sut.isOutOfBreeds == true)
        }

        // MARK: - dislikeBreed Tests

        @Test("dislikeBreed advances currentBreedID to next breed")
        func dislikeBreedAdvances() async {
            await stubBreedsWithImages()
            await sut.loadData()

            sut.dislikeBreed()
            #expect(sut.currentBreedID == "siam")
        }

        // MARK: - Computed Properties

        @Test("currentBreed returns breed matching currentBreedID")
        func currentBreedComputed() async {
            await stubBreedsWithImages()
            await sut.loadData()

            #expect(sut.currentBreed?.name == "Bengal")
        }

        @Test("imageURL returns url from breedImages for given ID")
        func imageURLFor() async {
            await stubBreedsWithImages()
            await sut.loadData()

            #expect(sut.imageURL(for: "beng") != nil)
        }

        @Test("imageURL returns nil for breed without image")
        func imageURLForNil() async {
            await stubBreedsWithImages()
            await sut.loadData()

            #expect(sut.imageURL(for: "norf") == nil)
        }

        // MARK: - setModelContext Tests

        @Test("setModelContext stores context, likeBreed persists without crash")
        func setModelContextAndVote() async throws {
            await stubBreedsWithImages()
            await sut.loadData()

            let config = ModelConfiguration(isStoredInMemoryOnly: true)
            let container = try ModelContainer(for: Vote.self, configurations: config)
            sut.setModelContext(container.mainContext)

            // Should not crash — saveVote executes modelContext.insert/save
            sut.likeBreed()
            #expect(sut.currentBreedID == "siam")
        }

        @Test("likeBreed works even without modelContext set")
        func likeBreedWithoutContext() async {
            await stubBreedsWithImages()
            await sut.loadData()

            sut.likeBreed()

            #expect(sut.currentBreedID == "siam")
        }

        // MARK: - retry Tests

        @Test("retry delegates to breedStore")
        func retryAfterError() async {
            await spyNetwork.setFailure(NetworkError.rateLimited, for: API.Endpoints.breeds)
            await sut.loadData()
            #expect(sut.errorMessage != nil)

            await stubBreedsWithImages()
            sut.retry()
            try? await Task.sleep(for: .milliseconds(100))

            #expect(breedStore.breeds.count == 3)
        }
    }
}
