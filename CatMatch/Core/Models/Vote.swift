//
//  Vote.swift
//  CatMatch
//
//  Created by Eduardo Andrade on 29/06/26.
//

import Foundation
import SwiftData

// MARK: - Vote

@Model
final class Vote {

    // MARK: - Properties

    @Attribute(.unique) var id: UUID
    var breedId: String
    var breedName: String
    var imageUrl: URL?
    var voteTypeRaw: String
    var date: Date

    // MARK: - Transient

    @Transient
    var voteType: VoteType {
        get { VoteType(rawValue: voteTypeRaw) ?? .like }
        set { voteTypeRaw = newValue.rawValue }
    }

    // MARK: - Initializers

    init(
        id: UUID = UUID(),
        breedId: String,
        breedName: String,
        imageUrl: URL? = nil,
        voteType: VoteType,
        date: Date = Date()
    ) {
        self.id = id
        self.breedId = breedId
        self.breedName = breedName
        self.imageUrl = imageUrl
        self.voteTypeRaw = voteType.rawValue
        self.date = date
    }
}

// MARK: - VoteType

extension Vote {

    enum VoteType: String, Codable, Sendable {
        case like, dislike
    }
}
