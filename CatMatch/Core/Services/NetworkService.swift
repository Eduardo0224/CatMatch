//
//  NetworkService.swift
//  CatMatch
//
//  Created by Eduardo Andrade on 29/06/26.
//

import Foundation

// MARK: - NetworkService

final class NetworkService: NetworkServiceProtocol {

    // MARK: - Private Properties

    private let session: URLSession
    private let apiKey: String

    // MARK: - Initializers

    init(session: URLSession = .shared) {
        self.session = session

        guard let key = Bundle.main.infoDictionary?["CATAPI_KEY"] as? String else {
            fatalError("CATAPI_KEY not found in Info.plist. Configure Secrets.xcconfig.")
        }
        self.apiKey = key
    }

    // MARK: - NetworkServiceProtocol

    func get<T: Decodable>(endpoint: String, queryItems: [URLQueryItem] = []) async throws -> T {
        var components = URLComponents(string: "\(API.baseURL)\(endpoint)")
        components?.queryItems = queryItems.isEmpty ? nil : queryItems

        guard let url = components?.url else {
            throw NetworkError.invalidURL
        }

        var request = URLRequest(url: url)
        request.setValue(apiKey, forHTTPHeaderField: "x-api-key")

        let (data, response) = try await session.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }

        switch httpResponse.statusCode {
        case 200...299:
            break
        case 401:
            throw NetworkError.unauthorized
        case 429:
            throw NetworkError.rateLimited
        default:
            throw NetworkError.httpError(statusCode: httpResponse.statusCode)
        }

        do {
            return try JSONDecoder().decode(T.self, from: data)
        } catch {
            throw NetworkError.decodingError(error)
        }
    }
}

// MARK: - NetworkError

enum NetworkError: LocalizedError {
    case invalidURL
    case invalidResponse
    case httpError(statusCode: Int)
    case decodingError(Error)
    case unauthorized
    case rateLimited

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            "Invalid URL"
        case .invalidResponse:
            "Invalid response from server"
        case .httpError(let statusCode):
            "HTTP error: \(statusCode)"
        case .decodingError(let error):
            "Decoding error: \(error.localizedDescription)"
        case .unauthorized:
            "Invalid API key"
        case .rateLimited:
            "Too many requests — try again later"
        }
    }
}
