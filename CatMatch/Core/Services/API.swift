//
//  API.swift
//  CatMatch
//
//  Created by Eduardo Andrade on 29/06/26.
//

import Foundation

// MARK: - API

enum API {
    static let baseURL = "https://api.thecatapi.com/v1"

    enum Endpoints {
        // MARK: - Breeds

        static let breeds = "/breeds"

        static func breedSearch(_ query: String) -> String {
            "/breeds/search?q=\(query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? query)"
        }

        static func breedByID(_ id: String) -> String {
            "/breeds/\(id)"
        }

        // MARK: - Images

        static let imagesSearch = "/images/search"

        static func imageSearch(breedIDs: String, limit: Int = 1) -> String {
            "/images/search?breed_ids=\(breedIDs)&limit=\(limit)"
        }

        static func imageByID(_ id: String) -> String {
            "/images/\(id)"
        }
    }

    enum Constants {
        static let defaultPageSize = 20
        static let maxPageSize = 40
    }
}
