//
//  CatImage.swift
//  CatMatch
//
//  Created by Eduardo Andrade on 29/06/26.
//

import Foundation

// MARK: - CatImage

struct CatImage: Identifiable, Codable, Sendable {
    let id: String
    let url: URL
    let width: Int
    let height: Int
    let breeds: [CatBreed]?
}
