//
//  L10n.swift
//  CatMatch
//
//  Created by Eduardo Andrade on 29/06/26.
//

import Foundation

// MARK: - L10n

/// Type-safe localization namespace using auto-generated String Catalog symbols.
/// Each .xcstrings catalog generates a type on `LocalizedStringResource`
/// accessible via dot notation (e.g., `.CatList.title`).
///
/// Usage:
/// ```
/// // SwiftUI
/// Text(L10n.CatList.title)
/// Text(L10n.Voting.like)
///
/// // UIKit
/// label.text = L10n.VoteHistory.title
/// button.setTitle(L10n.General.retry, for: .normal)
/// ```
enum L10n {

    // MARK: - CatList

    enum CatList {
        static let title = String(localized: .CatList.title)
        static let searchPrompt = String(localized: .CatList.searchPrompt)
        static let noResults = String(localized: .CatList.noResults)
    }

    // MARK: - CatDetail

    enum CatDetail {
        static let temperament = String(localized: .CatDetail.temperament)
        static let origin = String(localized: .CatDetail.origin)
        static let lifeSpan = String(localized: .CatDetail.lifeSpan)
        static let weight = String(localized: .CatDetail.weight)
    }

    // MARK: - Voting

    enum Voting {
        static let like = String(localized: .Voting.like)
        static let dislike = String(localized: .Voting.dislike)
        static let empty = String(localized: .Voting.empty)
    }

    // MARK: - VoteHistory

    enum VoteHistory {
        static let title = String(localized: .VoteHistory.title)
        static let filterAll = String(localized: .VoteHistory.filterAll)
        static let filterLikes = String(localized: .VoteHistory.filterLikes)
        static let filterDislikes = String(localized: .VoteHistory.filterDislikes)
        static let empty = String(localized: .VoteHistory.empty)
    }

    // MARK: - General

    enum General {
        static let retry = String(localized: .General.retry)
        static let loading = String(localized: .General.loading)
        static let errorTitle = String(localized: .General.errorTitle)
    }
}
