//
//  CatDetailTests+ViewModel.swift
//  CatMatchTests
//
//  Created by Eduardo Andrade on 29/06/26.
//

import Testing
@testable import CatMatch

// MARK: - CatDetailTests + ViewModel

extension CatDetailTests {

    @Suite("CatDetailViewModel Tests")
    @MainActor
    struct ViewModelTests {

        // MARK: - Subject Under Test

        let spyInteractor: SpyCatDetailInteractor

        func makeSUT(breed: CatBreed = CatDetailTestData.bengal, preloadedImage: CatImage? = nil) -> CatDetailViewModel {
            CatDetailViewModel(breed: breed, preloadedImage: preloadedImage, interactor: spyInteractor)
        }

        // MARK: - Initializers

        init() {
            self.spyInteractor = SpyCatDetailInteractor()
        }

        // MARK: - loadImage Tests

        @Test("preloadedImage skips network fetch")
        func preloadedImageSkipsFetch() async {
            let sut = makeSUT(preloadedImage: CatDetailTestData.bengalImage)

            await sut.loadImage()

            #expect(sut.hasPreloadedImage == true)
            #expect(sut.isLoadingImage == false)
            #expect(sut.image?.id == "img_beng")

            let callCount = await spyInteractor.fetchImageCallCount
            #expect(callCount == 0)
        }

        @Test("loadImage fetches when no preloaded image and breed has refID")
        func loadImageFetchesSuccessfully() async {
            await spyInteractor.setFetchImageResult(.success(CatDetailTestData.bengalImage))
            let sut = makeSUT()

            await sut.loadImage()

            #expect(sut.isLoadingImage == false)
            #expect(sut.image?.id == "img_beng")
            #expect(sut.imageErrorMessage == nil)

            let callCount = await spyInteractor.fetchImageCallCount
            #expect(callCount == 1)
        }

        @Test("loadImage sets error on network failure")
        func loadImageNetworkError() async {
            await spyInteractor.setFetchImageResult(.failure(NetworkError.rateLimited))
            let sut = makeSUT()

            await sut.loadImage()

            #expect(sut.isLoadingImage == false)
            #expect(sut.image == nil)
            #expect(sut.imageErrorMessage != nil)

            let callCount = await spyInteractor.fetchImageCallCount
            #expect(callCount == 1)
        }

        @Test("loadImage skips when breed has no referenceImageID")
        func loadImageSkipsWithoutRefID() async {
            let sut = makeSUT(breed: CatDetailTestData.breedWithoutRefID)

            await sut.loadImage()

            #expect(sut.isLoadingImage == false)
            #expect(sut.image == nil)
            #expect(sut.imageErrorMessage == nil)

            let callCount = await spyInteractor.fetchImageCallCount
            #expect(callCount == 0)
        }

        @Test("loadImage does not re-fetch when already loading")
        func loadImageNoReentry() async {
            await spyInteractor.setFetchImageResult(.success(CatDetailTestData.bengalImage))
            let sut = makeSUT()

            async let first = sut.loadImage()
            async let second = sut.loadImage()
            _ = await (first, second)

            let callCount = await spyInteractor.fetchImageCallCount
            #expect(callCount == 1)
        }

        // MARK: - Computed Properties Tests

        @Test("temperamentList splits comma-separated string")
        func temperamentList() {
            let sut = makeSUT()

            let traits = sut.temperamentList

            #expect(traits.count == 4)
            #expect(traits[0] == "Active")
            #expect(traits[1] == "Playful")
            #expect(traits[2] == "Intelligent")
            #expect(traits[3] == "Curious")
        }

        @Test("temperamentList handles empty temperament")
        func temperamentListEmpty() {
            let emptyBreed = CatBreed(
                id: "empty",
                name: "Empty",
                description: "",
                temperament: "",
                origin: "",
                lifeSpan: "",
                weight: Weight(imperial: "", metric: ""),
                referenceImageID: nil
            )
            let sut = makeSUT(breed: emptyBreed)

            #expect(sut.temperamentList.isEmpty)
        }

        @Test("weightDisplay formats metric weight")
        func weightDisplay() {
            let sut = makeSUT()

            #expect(sut.weightDisplay.contains("4 - 8"))
        }

        @Test("originDisplay returns breed origin")
        func originDisplay() {
            let sut = makeSUT()

            #expect(sut.originDisplay == "United States")
        }

        @Test("lifeSpanDisplay formats life span")
        func lifeSpanDisplay() {
            let sut = makeSUT()

            #expect(sut.lifeSpanDisplay.contains("12 - 15"))
        }
    }
}
