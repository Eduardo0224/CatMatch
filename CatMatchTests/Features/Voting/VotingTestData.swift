//
//  VotingTestData.swift
//  CatMatchTests
//
//  Created by Eduardo Andrade on 29/06/26.
//

import Foundation
@testable import CatMatch

// MARK: - VotingTestData

enum VotingTestData {

    // MARK: - Breeds

    static let bengal = CatBreed(
        id: "beng",
        name: "Bengal",
        description: "Bengals are active and intelligent.",
        temperament: "Active, Playful, Intelligent, Curious",
        origin: "United States",
        lifeSpan: "12 - 15",
        weight: Weight(imperial: "8 - 18", metric: "4 - 8"),
        referenceImageID: "beng_ref_001"
    )

    static let siamese = CatBreed(
        id: "siam",
        name: "Siamese",
        description: "The Siamese is a long, elegant cat.",
        temperament: "Active, Agile, Clever, Sociable",
        origin: "Thailand",
        lifeSpan: "12 - 15",
        weight: Weight(imperial: "6 - 12", metric: "3 - 5"),
        referenceImageID: "siam_ref_002"
    )

    static let norsk = CatBreed(
        id: "norf",
        name: "Norwegian Forest Cat",
        description: "The Norwegian Forest Cat is a sweet, loving cat.",
        temperament: "Sweet, Playful, Intelligent, Loving",
        origin: "Norway",
        lifeSpan: "14 - 16",
        weight: Weight(imperial: "10 - 20", metric: "5 - 9"),
        referenceImageID: nil
    )

    static let threeBreeds = [bengal, siamese, norsk]

    // MARK: - Images

    static let bengalImage = CatImage(
        id: "img_beng",
        url: URL(string: "https://cdn2.thecatapi.com/images/beng.jpg")!,
        width: 1200,
        height: 800,
        breeds: nil
    )
}
