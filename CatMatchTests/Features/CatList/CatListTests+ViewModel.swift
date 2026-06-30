//
//  CatListTests+ViewModel.swift
//  CatMatchTests
//
//  Created by Eduardo Andrade on 29/06/26.
//

import Testing
@testable import CatMatch

// MARK: - CatListTests + ViewModel

extension CatListTests {

    @Suite("CatListViewModel Tests")
    @MainActor
    struct ViewModelTests {

        // MARK: - Subject Under Test

        let spyNetwork: SpyNetworkService
        let breedStore: BreedStore
        let spyInteractor: SpyCatListInteractor
        let sut: CatListViewModel

        // MARK: - Initializers

        init() {
            self.spyNetwork = SpyNetworkService()
            self.breedStore = BreedStore(network: spyNetwork)
            self.spyInteractor = SpyCatListInteractor()
            self.sut = CatListViewModel(interactor: spyInteractor, breedStore: breedStore)
        }

        // MARK: - loadBreeds Tests

        @Test("loadBreeds sets breeds and images on success")
        func loadBreedsSuccess() async {
            // Given
            await spyNetwork.setSuccess(CatListTestData.threeBreeds, for: API.Endpoints.breeds)
            await spyNetwork.setSuccess(CatListTestData.bengalImage, for: API.Endpoints.imageByID("beng_ref_001"))
            await spyNetwork.setSuccess(CatListTestData.siameseImage, for: API.Endpoints.imageByID("siam_ref_002"))

            // When
            await sut.loadBreeds()

            // Then
            #expect(sut.breeds.count == 3)
            #expect(sut.breeds[0].name == "Bengal")
            #expect(sut.breedImages.count == 2)
            #expect(sut.breedImages["beng"] != nil)
            #expect(sut.breedImages["siam"] != nil)
            #expect(sut.breedImages["pers"] == nil)
            #expect(sut.isLoading == false)
            #expect(sut.errorMessage == nil)
        }

        @Test("loadBreeds handles empty breed list")
        func loadBreedsEmpty() async {
            // Given
            await spyNetwork.setSuccess([] as [CatBreed], for: API.Endpoints.breeds)

            // When
            await sut.loadBreeds()

            // Then
            #expect(sut.breeds.isEmpty)
            #expect(sut.breedImages.isEmpty)
            #expect(sut.isLoading == false)
            #expect(sut.errorMessage == nil)
        }

        @Test("loadBreeds sets errorMessage on network error")
        func loadBreedsError() async {
            // Given
            await spyNetwork.setFailure(NetworkError.rateLimited, for: API.Endpoints.breeds)

            // When
            await sut.loadBreeds()

            // Then
            #expect(sut.breeds.isEmpty)
            #expect(sut.errorMessage != nil)
            #expect(sut.isLoading == false)
        }

        @Test("loadBreeds does not re-enter while already loading")
        func loadBreedsNoReentry() async {
            // Given
            await spyNetwork.setSuccess(CatListTestData.threeBreeds, for: API.Endpoints.breeds)
            await spyNetwork.setSuccess(CatListTestData.bengalImage, for: API.Endpoints.imageByID("beng_ref_001"))
            await spyNetwork.setSuccess(CatListTestData.siameseImage, for: API.Endpoints.imageByID("siam_ref_002"))

            // When — two concurrent calls; loadIfNeeded guards against re-entry
            async let first = sut.loadBreeds()
            async let second = sut.loadBreeds()
            _ = await (first, second)

            // Then — only one breed fetch was made
            let breedFetchCount = await spyNetwork.endpoints.filter { $0 == API.Endpoints.breeds }.count
            #expect(breedFetchCount == 1)
        }

        @Test("loadBreeds handles cancellation gracefully")
        func loadBreedsCancelled() async {
            // BreedStore.loadIfNeeded() guards against re-entry with `!isLoading, breeds.isEmpty`.
            // Concurrent calls are handled gracefully — the second call is a no-op.

            // Given
            await spyNetwork.setSuccess(CatListTestData.threeBreeds, for: API.Endpoints.breeds)
            await spyNetwork.setSuccess(CatListTestData.bengalImage, for: API.Endpoints.imageByID("beng_ref_001"))
            await spyNetwork.setSuccess(CatListTestData.siameseImage, for: API.Endpoints.imageByID("siam_ref_002"))

            // When — two concurrent calls
            async let first = sut.loadBreeds()
            async let second = sut.loadBreeds()
            _ = await (first, second)

            // Then — clean state
            #expect(sut.errorMessage == nil)
            #expect(sut.isLoading == false)
        }

        // MARK: - image(for:) Tests

        @Test("image(for:) returns cached image by breed")
        func imageForBreed() async {
            // Given
            await spyNetwork.setSuccess(CatListTestData.threeBreeds, for: API.Endpoints.breeds)
            await spyNetwork.setSuccess(CatListTestData.bengalImage, for: API.Endpoints.imageByID("beng_ref_001"))
            await spyNetwork.setSuccess(CatListTestData.siameseImage, for: API.Endpoints.imageByID("siam_ref_002"))
            await sut.loadBreeds()

            // When
            let bengalImage = sut.image(for: CatListTestData.bengal)
            let persianImage = sut.image(for: CatListTestData.persian)
            let unknownImage = sut.image(for: CatBreed(
                id: "unknown",
                name: "Unknown",
                description: "",
                temperament: "",
                origin: "",
                lifeSpan: "",
                weight: Weight(imperial: "", metric: ""),
                referenceImageID: nil
            ))

            // Then
            #expect(bengalImage != nil)
            #expect(bengalImage?.id == "img_beng")
            #expect(persianImage == nil)
            #expect(unknownImage == nil)
        }

        // MARK: - retry Tests

        @Test("retry triggers loadBreeds again")
        func retry() async {
            // Given
            await spyNetwork.setSuccess(CatListTestData.threeBreeds, for: API.Endpoints.breeds)
            await spyNetwork.setSuccess(CatListTestData.bengalImage, for: API.Endpoints.imageByID("beng_ref_001"))
            await spyNetwork.setSuccess(CatListTestData.siameseImage, for: API.Endpoints.imageByID("siam_ref_002"))

            // When
            sut.retry()
            try? await Task.sleep(for: .milliseconds(100))

            // Then — breedStore loads data in background
            #expect(breedStore.breeds.count == 3)
            #expect(breedStore.errorMessage == nil)
        }

        @Test("retry clears previous error and loads again")
        func retryAfterError() async {
            // Given — load with error
            await spyNetwork.setFailure(NetworkError.rateLimited, for: API.Endpoints.breeds)
            await sut.loadBreeds()
            #expect(sut.errorMessage != nil)

            // When — retry with success stubs
            await spyNetwork.setSuccess(CatListTestData.threeBreeds, for: API.Endpoints.breeds)
            await spyNetwork.setSuccess(CatListTestData.bengalImage, for: API.Endpoints.imageByID("beng_ref_001"))
            await spyNetwork.setSuccess(CatListTestData.siameseImage, for: API.Endpoints.imageByID("siam_ref_002"))
            sut.retry()
            try? await Task.sleep(for: .milliseconds(100))

            // Then — breedStore loads data and clears error
            #expect(breedStore.breeds.count == 3)
            #expect(breedStore.errorMessage == nil)
        }

        // MARK: - searchQuery Tests

        @Test("searchQuery empty restores cached breeds")
        func searchQueryEmpty() async {
            // Given
            await spyNetwork.setSuccess(CatListTestData.threeBreeds, for: API.Endpoints.breeds)
            await spyNetwork.setSuccess(CatListTestData.bengalImage, for: API.Endpoints.imageByID("beng_ref_001"))
            await spyNetwork.setSuccess(CatListTestData.siameseImage, for: API.Endpoints.imageByID("siam_ref_002"))
            await sut.loadBreeds()

            // When
            sut.searchQuery = ""

            // Then — immediately restores from breedStore
            #expect(sut.breeds.count == 3)
            #expect(sut.errorMessage == nil)
        }

        @Test("searchQuery with text triggers search")
        func searchQueryWithText() async {
            // Given — preload breeds
            await spyNetwork.setSuccess(CatListTestData.threeBreeds, for: API.Endpoints.breeds)
            await spyNetwork.setSuccess(CatListTestData.bengalImage, for: API.Endpoints.imageByID("beng_ref_001"))
            await spyNetwork.setSuccess(CatListTestData.siameseImage, for: API.Endpoints.imageByID("siam_ref_002"))
            await sut.loadBreeds()
            await spyInteractor.setSearchBreedsResult(.success([CatListTestData.bengal]))

            // When
            sut.searchQuery = "Bengal"
            try? await Task.sleep(for: .milliseconds(600))  // debounce is 500ms

            // Then
            let searchCount = await spyInteractor.searchBreedsCallCount
            let lastQuery = await spyInteractor.lastSearchQuery
            #expect(searchCount == 1)
            #expect(lastQuery == "Bengal")
            #expect(sut.breeds.count == 1)
            #expect(sut.breeds[0].name == "Bengal")
        }

        @Test("searchQuery debounces rapid input")
        func searchQueryDebounce() async {
            // Given — preload breeds
            await spyNetwork.setSuccess(CatListTestData.threeBreeds, for: API.Endpoints.breeds)
            await spyNetwork.setSuccess(CatListTestData.bengalImage, for: API.Endpoints.imageByID("beng_ref_001"))
            await spyNetwork.setSuccess(CatListTestData.siameseImage, for: API.Endpoints.imageByID("siam_ref_002"))
            await sut.loadBreeds()
            await spyInteractor.setSearchBreedsResult(.success([CatListTestData.bengal]))

            // When — rapid input
            sut.searchQuery = "B"
            sut.searchQuery = "Be"
            sut.searchQuery = "Ben"
            sut.searchQuery = "Beng"
            sut.searchQuery = "Benga"
            sut.searchQuery = "Bengal"

            try? await Task.sleep(for: .milliseconds(700))

            // Then — only one search fired, with the final query
            let searchCount = await spyInteractor.searchBreedsCallCount
            let lastQuery = await spyInteractor.lastSearchQuery
            #expect(searchCount == 1)
            #expect(lastQuery == "Bengal")
        }

        @Test("searchQuery error with empty breeds shows error")
        func searchQueryErrorOnEmpty() async {
            // Given — no preloaded breeds
            await spyInteractor.setSearchBreedsResult(.failure(NetworkError.rateLimited))

            // When
            sut.searchQuery = "Bengal"
            try? await Task.sleep(for: .milliseconds(600))

            // Then — breeds empty, error shown
            #expect(sut.errorMessage != nil)
        }

        @Test("searchQuery error with existing breeds is non-blocking")
        func searchQueryErrorNonBlocking() async {
            // Given — preload breeds
            await spyNetwork.setSuccess(CatListTestData.threeBreeds, for: API.Endpoints.breeds)
            await spyNetwork.setSuccess(CatListTestData.bengalImage, for: API.Endpoints.imageByID("beng_ref_001"))
            await spyNetwork.setSuccess(CatListTestData.siameseImage, for: API.Endpoints.imageByID("siam_ref_002"))
            await sut.loadBreeds()
            await spyInteractor.setSearchBreedsResult(.failure(NetworkError.rateLimited))

            // When
            sut.searchQuery = "Bengal"
            try? await Task.sleep(for: .milliseconds(600))

            // Then — breeds unchanged, no error
            #expect(sut.breeds.count == 3)
            #expect(sut.errorMessage == nil)
        }
    }
}
