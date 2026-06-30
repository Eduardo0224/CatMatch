//
//  CatListTests+Interactor.swift
//  CatMatchTests
//
//  Created by Eduardo Andrade on 29/06/26.
//

import Testing
@testable import CatMatch

// MARK: - CatListTests + Interactor

extension CatListTests {

    @Suite("CatListInteractor Tests")
    struct InteractorTests {

        // MARK: - Subject Under Test

        let spyNetwork: SpyNetworkService
        let sut: CatListInteractor

        // MARK: - Initializers

        init() {
            self.spyNetwork = SpyNetworkService()
            self.sut = CatListInteractor(network: spyNetwork)
        }

        // MARK: - fetchBreedsWithImages Tests

        @Test("fetchBreedsWithImages returns breeds with their images")
        func fetchBreedsWithImagesSuccess() async throws {
            // Given
            await spyNetwork.setSuccess(CatListTestData.threeBreeds, for: API.Endpoints.breeds)
            await spyNetwork.setSuccess(CatListTestData.bengalImage, for: API.Endpoints.imageByID("beng_ref_001"))
            await spyNetwork.setSuccess(CatListTestData.siameseImage, for: API.Endpoints.imageByID("siam_ref_002"))

            // When
            let results = try await sut.fetchBreedsWithImages()

            // Then
            #expect(results.count == 3)
            #expect(results[0].breed.name == "Bengal")
            #expect(results[0].image?.id == "img_beng")
            #expect(results[1].breed.name == "Siamese")
            #expect(results[1].image?.id == "img_siam")
            #expect(results[2].breed.name == "Persian")
            #expect(results[2].image == nil) // persian has no referenceImageID
            let callCount = await spyNetwork.getCallCount
            #expect(callCount >= 3) // 1 breeds + 2 image fetches
        }

        @Test("fetchBreedsWithImages continues when image fetch fails")
        func fetchBreedsWithImagesPartialFailure() async throws {
            // Given
            await spyNetwork.setSuccess(CatListTestData.threeBreeds, for: API.Endpoints.breeds)
            await spyNetwork.setSuccess(CatListTestData.bengalImage, for: API.Endpoints.imageByID("beng_ref_001"))
            // siam image fetch fails
            await spyNetwork.setFailure(NetworkError.rateLimited, for: API.Endpoints.imageByID("siam_ref_002"))

            // When
            let results = try await sut.fetchBreedsWithImages()

            // Then
            #expect(results.count == 3)
            #expect(results[0].image != nil) // bengal succeeded
            #expect(results[1].image == nil) // siamese failed → nil
            #expect(results[2].image == nil) // persian has no ref ID
        }

        @Test("fetchBreedsWithImages propagates breed fetch error")
        func fetchBreedsWithImagesBreedError() async {
            // Given
            await spyNetwork.setFailure(NetworkError.rateLimited, for: API.Endpoints.breeds)

            // Then
            await #expect(throws: NetworkError.rateLimited) {
                // When
                _ = try await sut.fetchBreedsWithImages()
            }
        }

        // MARK: - searchBreeds Tests

        @Test("searchBreeds returns filtered breeds")
        func searchBreedsSuccess() async throws {
            // Given
            await spyNetwork.setSuccess([CatListTestData.bengal], for: API.Endpoints.breedSearch("Bengal"))

            // When
            let results = try await sut.searchBreeds(query: "Bengal")

            // Then
            #expect(results.count == 1)
            #expect(results[0].name == "Bengal")
            let lastEndpoint = await spyNetwork.lastEndpoint
            #expect(lastEndpoint == "/breeds/search?q=Bengal")
        }

        @Test("searchBreeds propagates error")
        func searchBreedsError() async {
            // Given
            await spyNetwork.setFailure(NetworkError.rateLimited, for: API.Endpoints.breedSearch("test"))

            // Then
            await #expect(throws: NetworkError.rateLimited) {
                // When
                _ = try await sut.searchBreeds(query: "test")
            }
        }

        // MARK: - fetchImage Tests

        @Test("fetchImage returns image for valid reference ID")
        func fetchImageSuccess() async throws {
            // Given
            await spyNetwork.setSuccess(CatListTestData.bengalImage, for: API.Endpoints.imageByID("beng_ref_001"))

            // When
            let image = try await sut.fetchImage(for: "beng_ref_001")

            // Then
            #expect(image?.id == "img_beng")
            let lastEndpoint = await spyNetwork.lastEndpoint
            #expect(lastEndpoint == "/images/beng_ref_001")
        }

        @Test("fetchImage propagates error")
        func fetchImageError() async {
            // Given
            await spyNetwork.setFailure(NetworkError.rateLimited, for: API.Endpoints.imageByID("bad_id"))

            // Then
            await #expect(throws: NetworkError.rateLimited) {
                // When
                _ = try await sut.fetchImage(for: "bad_id")
            }
        }
    }
}
