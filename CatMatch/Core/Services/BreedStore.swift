//
//  BreedStore.swift
//  CatMatch
//
//  Created by Eduardo Andrade on 29/06/26.
//

import Foundation
import Observation

// MARK: - BreedStore

/// Shared observable store that fetches breeds + images once and serves
/// both CatList and Voting features, eliminating duplicate `/breeds` requests.
@MainActor
@Observable
final class BreedStore: BreedStoreProtocol {

    // MARK: - Private Properties

    @ObservationIgnored
    private let network: NetworkServiceProtocol

    // MARK: - States

    private(set) var breeds: [CatBreed] = []
    private(set) var breedImages: [String: CatImage] = [:]
    private(set) var isLoading = false
    private(set) var errorMessage: String?

    // MARK: - Initializers

    init(network: NetworkServiceProtocol = NetworkService()) {
        self.network = network
    }

    // MARK: - Functions

    /// Fetches breeds and images from the API. Idempotent — skips if already loaded.
    func loadIfNeeded() async {
        guard !isLoading, breeds.isEmpty else { return }
        isLoading = true
        defer { isLoading = false }
        errorMessage = nil

        do {
            let breeds: [CatBreed] = try await network.get(
                endpoint: API.Endpoints.breeds,
                queryItems: [URLQueryItem(name: "limit", value: "\(API.Constants.maxPageSize)")]
            )

            let images = await fetchImagesInParallel(for: breeds)

            self.breeds = breeds
            self.breedImages = images
        } catch is CancellationError {
            errorMessage = nil
        } catch {
            if let networkError = error as? NetworkError {
                errorMessage = networkError.userMessage
            } else {
                errorMessage = L10n.Error.generic
            }
        }
    }

    func image(for breed: CatBreed) -> CatImage? {
        breedImages[breed.id]
    }

    func retry() {
        errorMessage = nil
        Task { await loadIfNeeded() }
    }

    // MARK: - Private Functions

    private func fetchImagesInParallel(for breeds: [CatBreed]) async -> [String: CatImage] {
        let network = self.network  // Capture Sendable dependency, not self
        return await withTaskGroup(of: (String, CatImage?).self) { group in
            for breed in breeds {
                guard let refID = breed.referenceImageID else { continue }
                group.addTask {
                    do {
                        let image: CatImage = try await network.get(
                            endpoint: API.Endpoints.imageByID(refID),
                            queryItems: []
                        )
                        return (breed.id, image)
                    } catch {
                        return (breed.id, nil)
                    }
                }
            }

            var images: [String: CatImage] = [:]
            for await (breedID, image) in group {
                if let image {
                    images[breedID] = image
                }
            }
            return images
        }
    }
}
