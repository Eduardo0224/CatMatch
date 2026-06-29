//
//  MockCatListInteractor.swift
//  CatMatch
//
//  Created by Eduardo Andrade on 29/06/26.
//

import Foundation

// MARK: - MockCatListInteractor

actor MockCatListInteractor: CatListInteractorProtocol {

    // MARK: - Mock Data

    static let mockBreeds: [CatBreed] = [
        CatBreed(
            id: "beng",
            name: "Bengal",
            description: "Bengals are a lot of fun to live with, but they're definitely not the cat for everyone. They are extremely active and intelligent.",
            temperament: "Active, Playful, Intelligent, Curious",
            origin: "United States",
            lifeSpan: "12 - 15",
            weight: Weight(imperial: "8 - 18", metric: "4 - 8"),
            referenceImageID: "vJ3lEYgXr"
        ),
        CatBreed(
            id: "siam",
            name: "Siamese",
            description: "The Siamese is a long, elegant cat. The body is long, the neck is long, the legs and tail are long.",
            temperament: "Active, Agile, Clever, Sociable",
            origin: "Thailand",
            lifeSpan: "12 - 15",
            weight: Weight(imperial: "6 - 12", metric: "3 - 5"),
            referenceImageID: "vJ3lEYgXr"
        ),
        CatBreed(
            id: "pers",
            name: "Persian",
            description: "The Persian is a heavily boned, well-balanced cat with a sweet expression and soft, round lines.",
            temperament: "Affectionate, Loyal, Sedate, Quiet",
            origin: "Iran",
            lifeSpan: "12 - 17",
            weight: Weight(imperial: "7 - 12", metric: "3 - 5"),
            referenceImageID: "vJ3lEYgXr"
        ),
    ]

    static let mockImage = CatImage(
        id: "mock_img",
        url: URL(string: "https://placehold.co/600x400")!,
        width: 600,
        height: 400,
        breeds: nil
    )

    // MARK: - Private Properties

    private let fetchBreedsResult: Result<[(breed: CatBreed, image: CatImage?)], Error>
    private let searchBreedsResult: Result<[CatBreed], Error>
    private let fetchImageResult: Result<CatImage?, Error>

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

    // MARK: - CatListInteractorProtocol

    func fetchBreedsWithImages() async throws -> [(breed: CatBreed, image: CatImage?)] {
        try fetchBreedsResult.get()
    }

    func searchBreeds(query: String) async throws -> [CatBreed] {
        try searchBreedsResult.get()
    }

    func fetchImage(for referenceImageID: String) async throws -> CatImage? {
        try fetchImageResult.get()
    }
}
