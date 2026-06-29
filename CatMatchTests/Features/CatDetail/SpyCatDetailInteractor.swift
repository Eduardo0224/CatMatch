//
//  SpyCatDetailInteractor.swift
//  CatMatchTests
//
//  Created by Eduardo Andrade on 29/06/26.
//

import Foundation
@testable import CatMatch

// MARK: - SpyCatDetailInteractor

actor SpyCatDetailInteractor: CatDetailInteractorProtocol {

    // MARK: - Call Tracking

    private(set) var fetchImageCallCount = 0
    private(set) var lastReferenceImageID: String?

    // MARK: - Injected Result

    var fetchImageResult: Result<CatImage?, Error>

    // MARK: - Initializers

    init(fetchImageResult: Result<CatImage?, Error> = .success(nil)) {
        self.fetchImageResult = fetchImageResult
    }

    // MARK: - Result Injection

    func setFetchImageResult(_ result: Result<CatImage?, Error>) {
        fetchImageResult = result
    }

    // MARK: - Reset

    func reset() {
        fetchImageCallCount = 0
        lastReferenceImageID = nil
    }

    // MARK: - CatDetailInteractorProtocol

    func fetchImage(for referenceImageID: String) async throws -> CatImage? {
        fetchImageCallCount += 1
        lastReferenceImageID = referenceImageID
        await Task.yield()
        return try fetchImageResult.get()
    }
}
