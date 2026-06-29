//
//  CatDetailInteractor.swift
//  CatMatch
//
//  Created by Eduardo Andrade on 29/06/26.
//

import Foundation

// MARK: - CatDetailInteractor

final class CatDetailInteractor: CatDetailInteractorProtocol {

    // MARK: - Private Properties

    private let network: NetworkServiceProtocol

    // MARK: - Initializers

    init(network: NetworkServiceProtocol = NetworkService()) {
        self.network = network
    }

    // MARK: - CatDetailInteractorProtocol

    func fetchImage(for referenceImageID: String) async throws -> CatImage? {
        let image: CatImage = try await network.get(
            endpoint: API.Endpoints.imageByID(referenceImageID),
            queryItems: []
        )
        return image
    }
}
