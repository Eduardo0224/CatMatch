//
//  SpyNetworkService.swift
//  CatMatchTests
//
//  Created by Eduardo Andrade on 29/06/26.
//

import Foundation
@testable import CatMatch

// MARK: - SpyNetworkService

/// Actor-based spy — mutable state is actor-isolated, no `@unchecked Sendable` needed.
actor SpyNetworkService: NetworkServiceProtocol {

    // MARK: - Call Tracking

    private(set) var getCallCount = 0
    private(set) var lastEndpoint: String?
    private(set) var lastQueryItems: [URLQueryItem]?
    private(set) var endpoints: [String] = []

    // MARK: - Stubs

    /// JSON-encoded success values — decoded to the requested type in `get`.
    private var successStubs: [String: Data] = [:]
    /// Stored network errors keyed by endpoint.
    private var failureStubs: [String: NetworkError] = [:]

    // MARK: - Stub Configuration

    func setSuccess<T: Encodable>(_ value: T, for endpoint: String) {
        successStubs[endpoint] = try! JSONEncoder().encode(value)
        failureStubs.removeValue(forKey: endpoint)
    }

    func setFailure(_ error: NetworkError, for endpoint: String) {
        failureStubs[endpoint] = error
        successStubs.removeValue(forKey: endpoint)
    }

    // MARK: - Reset

    func reset() {
        getCallCount = 0
        lastEndpoint = nil
        lastQueryItems = nil
        endpoints = []
        successStubs = [:]
        failureStubs = [:]
    }

    // MARK: - NetworkServiceProtocol

    func get<T: Decodable>(endpoint: String, queryItems: [URLQueryItem]) async throws -> T {
        getCallCount += 1
        lastEndpoint = endpoint
        lastQueryItems = queryItems
        endpoints.append(endpoint)

        if let error = failureStubs[endpoint] {
            throw error
        }

        guard let data = successStubs[endpoint] else {
            throw NetworkError.invalidURL
        }

        return try JSONDecoder().decode(T.self, from: data)
    }
}
