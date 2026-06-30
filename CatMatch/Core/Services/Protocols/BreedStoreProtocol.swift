//
//  BreedStoreProtocol.swift
//  CatMatch
//
//  Created by Eduardo Andrade on 29/06/26.
//

import Foundation
import Observation

// MARK: - BreedStoreProtocol

@MainActor
protocol BreedStoreProtocol: Observable {
    var breeds: [CatBreed] { get }
    var breedImages: [String: CatImage] { get }
    var isLoading: Bool { get }
    var errorMessage: String? { get }
    func loadIfNeeded() async
    func image(for breed: CatBreed) -> CatImage?
    func retry()
}
