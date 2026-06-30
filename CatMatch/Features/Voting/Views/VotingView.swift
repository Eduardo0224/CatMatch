//
//  VotingView.swift
//  CatMatch
//
//  Created by Eduardo Andrade on 29/06/26.
//

import SwiftUI
import SwiftData
import CatUI

// MARK: - VotingView

struct VotingView: View {

    // MARK: - Private Properties

    private let breedStore: any BreedStoreProtocol

    // MARK: - States

    @State private var viewModel: VotingViewModel
    @Environment(\.modelContext) private var modelContext

    // MARK: - Body

    var body: some View {
        Group {
            if viewModel.isLoading && viewModel.breeds.isEmpty {
                CatLoadingView()
            } else if let error = viewModel.errorMessage, !viewModel.isOutOfBreeds {
                CatErrorView(message: error, retryAction: viewModel.retry)
            } else if viewModel.isOutOfBreeds {
                CatEmptyView(
                    icon: "cat",
                    title: L10n.Voting.empty
                )
            } else {
                votingContent
            }
        }
        .navigationTitle(L10n.Voting.title)
        .task {
            viewModel.setModelContext(modelContext)
            guard !viewModel.isOutOfBreeds else { return }
            await viewModel.loadData()
        }
    }

    // MARK: - Initializers

    init(breedStore: any BreedStoreProtocol = BreedStore()) {
        self.breedStore = breedStore
        _viewModel = State(initialValue: VotingViewModel(breedStore: breedStore))
    }

    // MARK: - Private Views

    private var votingContent: some View {
        GeometryReader { proxy in
            let cardWidth = proxy.size.width * 0.78
            let peekInset = (proxy.size.width - cardWidth) / 2

            VStack(spacing: CatSpacing.spacing24) {
                ScrollView(.horizontal, showsIndicators: false) {
                    LazyHStack(spacing: 12) {
                        ForEach(viewModel.breeds) { breed in
                            VoteCardView(
                                breed: breed,
                                imageURL: viewModel.imageURL(for: breed.id),
                                cardWidth: cardWidth
                            )
                            .frame(width: cardWidth)
                            .padding(.vertical, CatSpacing.spacing12)
                            .scrollTransition(.interactive) { content, phase in
                                content
                                    .scaleEffect(phase.isIdentity ? 1 : 0.88)
                                    .opacity(phase.isIdentity ? 1 : 0.55)
                            }
                        }
                    }
                    .scrollTargetLayout()
                }
                .scrollClipDisabled(true)
                .scrollTargetBehavior(.viewAligned)
                .scrollPosition(id: $viewModel.currentBreedID)
                .contentMargins(.horizontal, peekInset, for: .scrollContent)

                HStack(spacing: CatSpacing.spacing32) {
                    CatButton(
                        L10n.Voting.dislike,
                        variant: .secondary,
                        action: { viewModel.dislikeBreed() }
                    )

                    CatButton(
                        L10n.Voting.like,
                        variant: .primary,
                        action: { viewModel.likeBreed() }
                    )
                }
                .padding(.horizontal, CatSpacing.spacing32)
            }
            .padding(.vertical, CatSpacing.spacing24)
        }
    }
}

// MARK: - Preview

#Preview("Voting - Loaded") {
    NavigationStack {
        VotingView(
            breedStore: MockBreedStore(
                breeds: [MockBreedStore.mockBreed],
                breedImages: ["beng": MockBreedStore.mockImage]
            )
        )
    }
}

#Preview("Voting - Loading") {
    NavigationStack {
        VotingView(breedStore: MockBreedStore(isLoading: true))
    }
}

#Preview("Voting - Empty") {
    NavigationStack {
        VotingView(breedStore: MockBreedStore(breeds: []))
    }
}

#Preview("Voting - Error") {
    NavigationStack {
        VotingView(
            breedStore: MockBreedStore(
                errorMessage: L10n.Error.rateLimited
            )
        )
    }
}
