//
//  CatDetailViewModelProtocol.swift
//  CatMatch
//
//  Created by Eduardo Andrade on 29/06/26.
//

import Foundation
import Observation

// MARK: - CatDetailViewModelProtocol

@MainActor
protocol CatDetailViewModelProtocol: Observable {
    var breed: CatBreed { get }
    var image: CatImage? { get }
    var isLoadingImage: Bool { get }
    var imageErrorMessage: String? { get }
    var temperamentList: [String] { get }
    var weightDisplay: String { get }
    var originDisplay: String { get }
    var lifeSpanDisplay: String { get }
    func loadImage() async
}
