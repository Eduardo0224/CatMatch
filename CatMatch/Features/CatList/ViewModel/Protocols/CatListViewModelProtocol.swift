//
//  CatListViewModelProtocol.swift
//  CatMatch
//
//  Created by Eduardo Andrade on 29/06/26.
//

import Foundation
import Observation

// MARK: - CatListViewModelProtocol

@MainActor
protocol CatListViewModelProtocol: Observable {
    var breeds: [CatBreed] { get }
    var breedImages: [String: CatImage] { get }
    var isLoading: Bool { get }
    var errorMessage: String? { get }
    var searchQuery: String { get set }
    func loadBreeds() async
    func retry()
    func image(for breed: CatBreed) -> CatImage?
}
