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

        let spyInteractor: SpyCatListInteractor
        var sut: CatListViewModel {
            CatListViewModel(interactor: spyInteractor)
        }

        // MARK: - Initializers

        init() {
            self.spyInteractor = SpyCatListInteractor()
        }

        // MARK: - loadBreeds Tests

        @Test("loadBreeds sets breeds and images on success")
        func loadBreedsSuccess() async {
            await spyInteractor.setFetchBreedsResult(.success(CatListTestData.breedsWithImages))
            let sut = sut

            await sut.loadBreeds()

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
            await spyInteractor.setFetchBreedsResult(.success([]))
            let sut = sut

            await sut.loadBreeds()

            #expect(sut.breeds.isEmpty)
            #expect(sut.breedImages.isEmpty)
            #expect(sut.isLoading == false)
            #expect(sut.errorMessage == nil)
        }

        @Test("loadBreeds sets errorMessage on network error")
        func loadBreedsError() async {
            await spyInteractor.setFetchBreedsResult(.failure(NetworkError.rateLimited))
            let sut = sut

            await sut.loadBreeds()

            #expect(sut.breeds.isEmpty)
            #expect(sut.errorMessage != nil)
            #expect(sut.isLoading == false)
        }

        @Test("loadBreeds does not re-enter while already loading")
        func loadBreedsNoReentry() async {
            await spyInteractor.reset()
            await spyInteractor.setFetchBreedsResult(.success(CatListTestData.breedsWithImages))
            let sut = sut

            async let first = sut.loadBreeds()
            async let second = sut.loadBreeds()
            _ = await (first, second)

            let callCount = await spyInteractor.fetchBreedsWithImagesCallCount
            #expect(callCount == 1)
        }

        @Test("loadBreeds handles cancellation gracefully")
        func loadBreedsCancelled() async {
            await spyInteractor.setFetchBreedsResult(.failure(CancellationError()))
            let sut = sut

            await sut.loadBreeds()

            #expect(sut.errorMessage == nil)
            #expect(sut.isLoading == false)
        }

        // MARK: - image(for:) Tests

        @Test("image(for:) returns cached image by breed")
        func imageForBreed() async {
            await spyInteractor.setFetchBreedsResult(.success(CatListTestData.breedsWithImages))
            let sut = sut
            await sut.loadBreeds()

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

            #expect(bengalImage != nil)
            #expect(bengalImage?.id == "img_beng")
            #expect(persianImage == nil)
            #expect(unknownImage == nil)
        }

        // MARK: - retry Tests

        @Test("retry triggers loadBreeds again")
        func retry() async {
            await spyInteractor.setFetchBreedsResult(.success(CatListTestData.breedsWithImages))
            let sut = sut

            sut.retry()

            // retry uses Task so need a brief wait
            try? await Task.sleep(for: .milliseconds(100))

            let callCount = await spyInteractor.fetchBreedsWithImagesCallCount
            #expect(callCount == 1)
            #expect(sut.breeds.count == 3)
        }

        @Test("retry clears previous error and loads again")
        func retryAfterError() async {
            await spyInteractor.setFetchBreedsResult(.failure(NetworkError.rateLimited))
            let sut = sut
            await sut.loadBreeds()
            #expect(sut.errorMessage != nil)

            await spyInteractor.setFetchBreedsResult(.success(CatListTestData.breedsWithImages))
            sut.retry()
            try? await Task.sleep(for: .milliseconds(100))

            #expect(sut.breeds.count == 3)
        }

        // MARK: - searchQuery Tests

        @Test("searchQuery empty restores cached breeds")
        func searchQueryEmpty() async {
            await spyInteractor.setFetchBreedsResult(.success(CatListTestData.breedsWithImages))
            let sut = sut
            await sut.loadBreeds()

            sut.searchQuery = ""
            // Give the search task a moment to resolve
            try? await Task.sleep(for: .milliseconds(50))

            #expect(sut.breeds.count == 3)
            #expect(sut.errorMessage == nil)
        }

        @Test("searchQuery with text triggers search")
        func searchQueryWithText() async {
            await spyInteractor.setFetchBreedsResult(.success(CatListTestData.breedsWithImages))
            await spyInteractor.setSearchBreedsResult(.success([CatListTestData.bengal]))
            let sut = sut
            await sut.loadBreeds()

            sut.searchQuery = "Bengal"
            try? await Task.sleep(for: .milliseconds(600))  // debounce is 500ms

            let searchCount = await spyInteractor.searchBreedsCallCount
            let lastQuery = await spyInteractor.lastSearchQuery
            #expect(searchCount == 1)
            #expect(lastQuery == "Bengal")
            #expect(sut.breeds.count == 1)
            #expect(sut.breeds[0].name == "Bengal")
        }

        @Test("searchQuery debounces rapid input")
        func searchQueryDebounce() async {
            await spyInteractor.setFetchBreedsResult(.success(CatListTestData.breedsWithImages))
            await spyInteractor.setSearchBreedsResult(.success([CatListTestData.bengal]))
            let sut = sut
            await sut.loadBreeds()

            sut.searchQuery = "B"
            sut.searchQuery = "Be"
            sut.searchQuery = "Ben"
            sut.searchQuery = "Beng"
            sut.searchQuery = "Benga"
            sut.searchQuery = "Bengal"

            try? await Task.sleep(for: .milliseconds(700))

            let searchCount = await spyInteractor.searchBreedsCallCount
            let lastQuery = await spyInteractor.lastSearchQuery
            #expect(searchCount == 1)
            #expect(lastQuery == "Bengal")
        }

        @Test("searchQuery error with empty breeds shows error")
        func searchQueryErrorOnEmpty() async {
            // Don't load breeds first — breeds list is empty
            await spyInteractor.setSearchBreedsResult(.failure(NetworkError.rateLimited))
            let sut = sut

            sut.searchQuery = "Bengal"
            try? await Task.sleep(for: .milliseconds(600))

            #expect(sut.errorMessage != nil)
        }

        @Test("searchQuery error with existing breeds is non-blocking")
        func searchQueryErrorNonBlocking() async {
            await spyInteractor.setFetchBreedsResult(.success(CatListTestData.breedsWithImages))
            await spyInteractor.setSearchBreedsResult(.failure(NetworkError.rateLimited))
            let sut = sut
            await sut.loadBreeds()

            sut.searchQuery = "Bengal"
            try? await Task.sleep(for: .milliseconds(600))

            // Non-blocking error: breeds stay as previous, no error message
            #expect(sut.breeds.count == 3)
            #expect(sut.errorMessage == nil)
        }
    }
}
