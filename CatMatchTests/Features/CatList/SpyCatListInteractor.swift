//
//  SpyCatListInteractor.swift
//  CatMatchTests
//
//  Created by Eduardo Andrade on 29/06/26.
//

import Foundation
@testable import CatMatch

// MARK: - SpyCatListInteractor

/// Actor-based spy — mutable state is actor-isolated, no `@unchecked Sendable` needed.
actor SpyCatListInteractor: CatListInteractorProtocol {

    // MARK: - Call Tracking

    private(set) var fetchBreedsWithImagesCallCount = 0
    private(set) var searchBreedsCallCount = 0
    private(set) var fetchImageCallCount = 0
    private(set) var lastSearchQuery: String?
    private(set) var lastFetchImageID: String?

    // MARK: - Injected Results

    var fetchBreedsResult: Result<[(breed: CatBreed, image: CatImage?)], Error>
    var searchBreedsResult: Result<[CatBreed], Error>
    var fetchImageResult: Result<CatImage?, Error>

    // MARK: - Initializers

    init(
        fetchBreedsResult: Result<[(breed: CatBreed, image: CatImage?)], Error> = .success([]),
        searchBreedsResult: Result<[CatBreed], Error> = .success([]),
        fetchImageResult: Result<CatImage?, Error> = .success(nil)
    ) {
        self.fetchBreedsResult = fetchBreedsResult
        self.searchBreedsResult = searchBreedsResult
        self.fetchImageResult = fetchImageResult
    }

    // MARK: - Result Injection

    func setFetchBreedsResult(_ result: Result<[(breed: CatBreed, image: CatImage?)], Error>) {
        fetchBreedsResult = result
    }

    func setSearchBreedsResult(_ result: Result<[CatBreed], Error>) {
        searchBreedsResult = result
    }

    // MARK: - Reset

    func reset() {
        fetchBreedsWithImagesCallCount = 0
        searchBreedsCallCount = 0
        fetchImageCallCount = 0
        lastSearchQuery = nil
        lastFetchImageID = nil
    }

    // MARK: - CatListInteractorProtocol

    func fetchBreedsWithImages() async throws -> [(breed: CatBreed, image: CatImage?)] {
        fetchBreedsWithImagesCallCount += 1
        await Task.yield()
        return try fetchBreedsResult.get()
    }

    func searchBreeds(query: String) async throws -> [CatBreed] {
        searchBreedsCallCount += 1
        lastSearchQuery = query
        await Task.yield()
        return try searchBreedsResult.get()
    }

    func fetchImage(for referenceImageID: String) async throws -> CatImage? {
        fetchImageCallCount += 1
        lastFetchImageID = referenceImageID
        await Task.yield()
        return try fetchImageResult.get()
    }
}
