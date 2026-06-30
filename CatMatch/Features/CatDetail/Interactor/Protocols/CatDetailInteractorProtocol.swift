//
//  CatDetailInteractorProtocol.swift
//  CatMatch
//
//  Created by Eduardo Andrade on 29/06/26.
//

import Foundation

// MARK: - CatDetailInteractorProtocol

protocol CatDetailInteractorProtocol: Sendable {
    /// Fetch the hero image for a specific breed reference image ID.
    func fetchImage(for referenceImageID: String) async throws -> CatImage?
}
