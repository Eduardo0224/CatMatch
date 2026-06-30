//
//  MockBreedStore.swift
//  CatMatch
//
//  Created by Eduardo Andrade on 29/06/26.
//

import Foundation
import Observation

// MARK: - MockBreedStore

/// Pre-populated breed store for SwiftUI previews. No network calls.
@MainActor
@Observable
final class MockBreedStore: BreedStoreProtocol {

    // MARK: - Mock Static Data

    static let mockBreed = CatBreed(
        id: "beng", name: "Bengal",
        description: "Bengals are a lot of fun to live with.",
        temperament: "Active, Playful",
        origin: "United States", lifeSpan: "12 - 15",
        weight: Weight(imperial: "8 - 18", metric: "4 - 8"),
        referenceImageID: "vJ3lEYgXr"
    )

    static let mockImage = CatImage(
        id: "img", url: URL(string: "https://placehold.co/600x400")!,
        width: 600, height: 400, breeds: nil
    )

    // MARK: - States

    private(set) var breeds: [CatBreed] = []
    private(set) var breedImages: [String: CatImage] = [:]
    private(set) var isLoading = false
    private(set) var errorMessage: String?

    // MARK: - Initializers

    init(
        breeds: [CatBreed] = [],
        breedImages: [String: CatImage] = [:],
        isLoading: Bool = false,
        errorMessage: String? = nil
    ) {
        self.breeds = breeds
        self.breedImages = breedImages
        self.isLoading = isLoading
        self.errorMessage = errorMessage
    }

    // MARK: - BreedStoreProtocol

    func loadIfNeeded() async { /* no-op: data injected via init */ }

    func image(for breed: CatBreed) -> CatImage? {
        breedImages[breed.id]
    }

    func retry() { /* no-op */ }
}
