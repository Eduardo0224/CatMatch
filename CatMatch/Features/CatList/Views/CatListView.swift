//
//  CatListView.swift
//  CatMatch
//
//  Created by Eduardo Andrade on 29/06/26.
//

import SwiftUI
import CatUI

// MARK: - CatListView

struct CatListView: View {

    // MARK: - Private Properties

    private let interactor: CatListInteractorProtocol

    // MARK: - States

    @State private var viewModel: CatListViewModel

    // MARK: - Body

    var body: some View {
        Group {
            if viewModel.isLoading && viewModel.breeds.isEmpty {
                CatLoadingView()
            } else if let error = viewModel.errorMessage, viewModel.breeds.isEmpty {
                CatErrorView(message: error, retryAction: viewModel.retry)
            } else if viewModel.breeds.isEmpty {
                CatEmptyView(
                    icon: "cat",
                    title: L10n.CatList.noResults
                )
            } else {
                contentList
            }
        }
        .navigationTitle(L10n.CatList.title)
        .searchable(text: $viewModel.searchQuery, prompt: L10n.CatList.searchPrompt)
        .task { await viewModel.loadBreeds() }
    }

    // MARK: - Initializers

    init(interactor: CatListInteractorProtocol = CatListInteractor()) {
        self.interactor = interactor
        _viewModel = State(initialValue: CatListViewModel(interactor: interactor))
    }

    // MARK: - Private Views

    private var contentList: some View {
        List(viewModel.breeds) { breed in
            NavigationLink(destination: CatDetailView(
                breed: breed,
                preloadedImage: viewModel.image(for: breed),
                interactor: interactor
            )) {
                CatListRowView(
                    breed: breed,
                    image: viewModel.image(for: breed)
                )
            }
            .navigationLinkIndicatorVisibility(.hidden)
            .listRowSeparator(.hidden)
            .listRowInsets(EdgeInsets(
                top: CatSpacing.spacing8,
                leading: CatSpacing.spacing16,
                bottom: CatSpacing.spacing8,
                trailing: CatSpacing.spacing16
            ))
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
    }
}

// MARK: - Preview

#Preview("CatList - Loaded") {
    NavigationStack {
        CatListView(
            interactor: MockCatListInteractor(
                fetchBreedsResult: .success(
                    MockCatListInteractor.mockBreeds.map { ($0, MockCatListInteractor.mockImage) }
                )
            )
        )
    }
}

#Preview("CatList - Loading") {
    NavigationStack {
        CatListView(interactor: MockCatListInteractor())
    }
}

#Preview("CatList - Empty") {
    NavigationStack {
        CatListView(
            interactor: MockCatListInteractor(
                fetchBreedsResult: .success([])
            )
        )
    }
}

#Preview("CatList - Error") {
    NavigationStack {
        CatListView(
            interactor: MockCatListInteractor(
                fetchBreedsResult: .failure(NetworkError.rateLimited)
            )
        )
    }
}
