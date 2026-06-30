//
//  NetworkServiceProtocol.swift
//  CatMatch
//
//  Created by Eduardo Andrade on 29/06/26.
//

import Foundation

// MARK: - NetworkServiceProtocol

protocol NetworkServiceProtocol: Sendable {
    func get<T: Decodable>(endpoint: String, queryItems: [URLQueryItem]) async throws -> T
}
