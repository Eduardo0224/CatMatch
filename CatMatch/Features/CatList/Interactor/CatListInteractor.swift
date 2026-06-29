//
//  CatListInteractor.swift
//  CatMatch
//
//  Created by Eduardo Andrade on 29/06/26.
//

import Foundation

// MARK: - CatListInteractor

final class CatListInteractor: CatListInteractorProtocol {

    // MARK: - Private Properties

    private let network: NetworkServiceProtocol

    // MARK: - Initializers

    init(network: NetworkServiceProtocol = NetworkService()) {
        self.network = network
    }

    // MARK: - CatListInteractorProtocol

    func fetchBreedsWithImages() async throws -> [(breed: CatBreed, image: CatImage?)] {
        let breeds: [CatBreed] = try await network.get(
            endpoint: API.Endpoints.breeds,
            queryItems: [URLQueryItem(name: "limit", value: "\(API.Constants.maxPageSize)")]
        )

        return await withTaskGroup(of: (Int, CatImage?).self) { group in
            for (index, breed) in breeds.enumerated() {
                guard let refID = breed.referenceImageID else {
                    continue
                }
                group.addTask {
                    do {
                        let image: CatImage = try await self.network.get(
                            endpoint: API.Endpoints.imageByID(refID),
                            queryItems: []
                        )
                        return (index, image)
                    } catch {
                        return (index, nil)
                    }
                }
            }

            var images = [Int: CatImage]()
            for await (index, image) in group {
                if let image {
                    images[index] = image
                }
            }

            return breeds.enumerated().map { (index, breed) in
                (breed, images[index])
            }
        }
    }

    func searchBreeds(query: String) async throws -> [CatBreed] {
        let breeds: [CatBreed] = try await network.get(
            endpoint: API.Endpoints.breedSearch(query),
            queryItems: []
        )
        return breeds
    }

    func fetchImage(for referenceImageID: String) async throws -> CatImage? {
        let image: CatImage = try await network.get(
            endpoint: API.Endpoints.imageByID(referenceImageID),
            queryItems: []
        )
        return image
    }
}
