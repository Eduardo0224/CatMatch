//
//  CatBreed.swift
//  CatMatch
//
//  Created by Eduardo Andrade on 29/06/26.
//

import Foundation

// MARK: - CatBreed

struct CatBreed: Identifiable, Codable, Sendable {
    let id: String
    let name: String
    let description: String
    let temperament: String
    let origin: String
    let lifeSpan: String
    let weight: Weight
    let referenceImageID: String?

    enum CodingKeys: String, CodingKey {
        case id, name, description, temperament, origin
        case lifeSpan = "life_span"
        case weight
        case referenceImageID = "reference_image_id"
    }
}

// MARK: - Weight

struct Weight: Codable, Sendable {
    let imperial: String
    let metric: String
}
