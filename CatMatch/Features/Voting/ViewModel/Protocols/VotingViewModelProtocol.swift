//
//  VotingViewModelProtocol.swift
//  CatMatch
//
//  Created by Eduardo Andrade on 29/06/26.
//

import Foundation
import Observation
import SwiftData

// MARK: - VotingViewModelProtocol

@MainActor
protocol VotingViewModelProtocol: Observable {
    var breeds: [CatBreed] { get }
    var breedImages: [String: CatImage] { get }
    var isLoading: Bool { get }
    var errorMessage: String? { get }
    var isOutOfBreeds: Bool { get }
    var currentBreedID: String? { get set }
    var currentBreed: CatBreed? { get }
    func imageURL(for breedID: String) -> URL?
    func setModelContext(_ context: ModelContext)
    func loadData() async
    func likeBreed()
    func dislikeBreed()
    func retry()
}
