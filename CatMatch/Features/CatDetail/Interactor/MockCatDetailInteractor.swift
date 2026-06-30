//
//  MockCatDetailInteractor.swift
//  CatMatch
//
//  Created by Eduardo Andrade on 29/06/26.
//

import Foundation

// MARK: - MockCatDetailInteractor

actor MockCatDetailInteractor: CatDetailInteractorProtocol {

    // MARK: - Mock Data

    static let mockImage = CatImage(
        id: "detail_mock_img",
        url: URL(string: "https://placehold.co/600x400")!,
        width: 600,
        height: 400,
        breeds: nil
    )

    static let mockBreed = CatBreed(
        id: "beng",
        name: "Bengal",
        description: "Bengals are a lot of fun to live with, but they're definitely not the cat for everyone.",
        temperament: "Active, Playful, Intelligent, Curious",
        origin: "United States",
        lifeSpan: "12 - 15",
        weight: Weight(imperial: "8 - 18", metric: "4 - 8"),
        referenceImageID: "vJ3lEYgXr"
    )

    // MARK: - Private Properties

    private let fetchImageResult: Result<CatImage?, Error>

    // MARK: - Initializers

    init(fetchImageResult: Result<CatImage?, Error> = .success(MockCatDetailInteractor.mockImage)) {
        self.fetchImageResult = fetchImageResult
    }

    // MARK: - CatDetailInteractorProtocol

    func fetchImage(for referenceImageID: String) async throws -> CatImage? {
        try fetchImageResult.get()
    }
}
