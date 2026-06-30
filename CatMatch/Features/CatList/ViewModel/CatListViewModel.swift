//
//  CatListViewModel.swift
//  CatMatch
//
//  Created by Eduardo Andrade on 29/06/26.
//

import Foundation
import Observation

// MARK: - CatListViewModel

@Observable
final class CatListViewModel: CatListViewModelProtocol {

    // MARK: - Private Properties

    @ObservationIgnored
    private let interactor: CatListInteractorProtocol

    @ObservationIgnored
    private let breedStore: any BreedStoreProtocol

    @ObservationIgnored
    private var searchTask: Task<Void, Never>?

    // MARK: - States

    private(set) var breeds: [CatBreed] = []
    private(set) var breedImages: [String: CatImage] = [:]
    private(set) var isLoading = false
    private(set) var errorMessage: String?
    var searchQuery = "" {
        didSet { handleSearchQueryChange() }
    }

    // MARK: - Initializers

    init(interactor: CatListInteractorProtocol, breedStore: any BreedStoreProtocol) {
        self.interactor = interactor
        self.breedStore = breedStore
    }

    // MARK: - Functions

    func image(for breed: CatBreed) -> CatImage? {
        breedStore.image(for: breed)
    }

    func loadBreeds() async {
        await breedStore.loadIfNeeded()
        syncFromStore()
    }

    func retry() {
        breedStore.retry()
    }

    // MARK: - Private Functions

    private func syncFromStore() {
        breeds = breedStore.breeds
        breedImages = breedStore.breedImages
        isLoading = breedStore.isLoading
        errorMessage = breedStore.errorMessage
    }

    private func handleError(_ error: Error) {
        if let networkError = error as? NetworkError {
            errorMessage = networkError.userMessage
        } else {
            errorMessage = L10n.Error.generic
        }
        print("[CatListViewModel] Error: \(error)")
    }

    private func handleSearchQueryChange() {
        searchTask?.cancel()

        guard !searchQuery.isEmpty else {
            breeds = breedStore.breeds
            errorMessage = nil
            return
        }

        searchTask = Task { [weak self] in
            guard let self else { return }

            try? await Task.sleep(for: .milliseconds(500))

            guard !Task.isCancelled else { return }

            do {
                let results = try await self.interactor.searchBreeds(query: self.searchQuery)
                guard !Task.isCancelled else { return }
                self.breeds = results
                self.errorMessage = nil
            } catch {
                guard !Task.isCancelled else { return }
                self.handleSearchError(error)
            }
        }
    }

    private func handleSearchError(_ error: Error) {
        guard breeds.isEmpty else {
            print("[CatListViewModel] Search error (non-blocking): \(error)")
            return
        }
        handleError(error)
    }
}
