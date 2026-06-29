//
//  CatListInteractorProtocol.swift
//  CatMatch
//
//  Created by Eduardo Andrade on 29/06/26.
//

import Foundation

// MARK: - CatListInteractorProtocol

protocol CatListInteractorProtocol: CatDetailInteractorProtocol, Sendable {
    /// Fetch all breeds with their primary images batched in parallel.
    func fetchBreedsWithImages() async throws -> [(breed: CatBreed, image: CatImage?)]

    /// Search breeds by query string via `/breeds/search`.
    /// Does NOT fetch images — returns breeds only.
    func searchBreeds(query: String) async throws -> [CatBreed]
}
