//
//  VoteHistoryTestData.swift
//  CatMatchTests
//
//  Created by Eduardo Andrade on 29/06/26.
//

import Foundation
@testable import CatMatch

// MARK: - VoteHistoryTestData

enum VoteHistoryTestData {

    // MARK: - Dates

    static let date1 = Date(timeIntervalSinceNow: -3600)       // 1 hour ago
    static let date2 = Date(timeIntervalSinceNow: -7200)       // 2 hours ago
    static let date3 = Date(timeIntervalSinceNow: -10800)      // 3 hours ago

    // MARK: - Vote Factory

    @MainActor
    static func makeVote(
        id: UUID = UUID(),
        breedId: String = "test_breed",
        breedName: String = "Test Cat",
        imageUrl: URL? = nil,
        voteType: Vote.VoteType = .like,
        date: Date = Date()
    ) -> Vote {
        Vote(
            id: id,
            breedId: breedId,
            breedName: breedName,
            imageUrl: imageUrl,
            voteType: voteType,
            date: date
        )
    }

    // MARK: - Sample Votes

    @MainActor
    static func sampleLikeVote() -> Vote {
        makeVote(
            id: UUID(),
            breedId: "beng",
            breedName: "Bengal",
            imageUrl: URL(string: "https://cdn2.thecatapi.com/images/beng.jpg"),
            voteType: .like,
            date: date1
        )
    }

    @MainActor
    static func sampleDislikeVote() -> Vote {
        makeVote(
            id: UUID(),
            breedId: "siam",
            breedName: "Siamese",
            imageUrl: URL(string: "https://cdn2.thecatapi.com/images/siam.jpg"),
            voteType: .dislike,
            date: date2
        )
    }

    @MainActor
    static func sampleLikeVote2() -> Vote {
        makeVote(
            id: UUID(),
            breedId: "norf",
            breedName: "Norwegian Forest Cat",
            imageUrl: nil,
            voteType: .like,
            date: date3
        )
    }
}
