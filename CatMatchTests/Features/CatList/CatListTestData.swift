//
//  CatListTestData.swift
//  CatMatchTests
//
//  Created by Eduardo Andrade on 29/06/26.
//

import Foundation
@testable import CatMatch

// MARK: - CatListTestData

enum CatListTestData {

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

    static let persian = CatBreed(
        id: "pers",
        name: "Persian",
        description: "The Persian is a heavily boned cat.",
        temperament: "Affectionate, Loyal, Sedate, Quiet",
        origin: "Iran",
        lifeSpan: "12 - 17",
        weight: Weight(imperial: "7 - 12", metric: "3 - 5"),
        referenceImageID: nil
    )

    static let threeBreeds = [bengal, siamese, persian]

    // MARK: - Images

    static let bengalImage = CatImage(
        id: "img_beng",
        url: URL(string: "https://cdn2.thecatapi.com/images/beng.jpg")!,
        width: 1200,
        height: 800,
        breeds: nil
    )

    static let siameseImage = CatImage(
        id: "img_siam",
        url: URL(string: "https://cdn2.thecatapi.com/images/siam.jpg")!,
        width: 1000,
        height: 900,
        breeds: nil
    )

    // MARK: - Breed+Image pairs (fetchBreedsWithImages result)

    static let breedsWithImages: [(breed: CatBreed, image: CatImage?)] = [
        (bengal, bengalImage),
        (siamese, siameseImage),
        (persian, nil),
    ]
}
