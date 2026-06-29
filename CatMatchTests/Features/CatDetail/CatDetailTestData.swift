//
//  CatDetailTestData.swift
//  CatMatchTests
//
//  Created by Eduardo Andrade on 29/06/26.
//

import Foundation
@testable import CatMatch

// MARK: - CatDetailTestData

enum CatDetailTestData {

    // MARK: - Breed

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

    static let breedWithoutRefID = CatBreed(
        id: "noref",
        name: "No Ref",
        description: "Breed without a reference image.",
        temperament: "Calm",
        origin: "Unknown",
        lifeSpan: "10 - 12",
        weight: Weight(imperial: "5 - 10", metric: "2 - 5"),
        referenceImageID: nil
    )

    // MARK: - Image

    static let bengalImage = CatImage(
        id: "img_beng",
        url: URL(string: "https://cdn2.thecatapi.com/images/beng.jpg")!,
        width: 1200,
        height: 800,
        breeds: nil
    )
}
