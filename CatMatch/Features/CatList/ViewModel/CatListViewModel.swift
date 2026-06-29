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
    private var searchTask: Task<Void, Never>?

    @ObservationIgnored
    private var cachedBreeds: [CatBreed] = []

    // MARK: - States

    private(set) var breeds: [CatBreed] = []
    private(set) var breedImages: [String: CatImage] = [:]
    private(set) var isLoading = false
    private(set) var errorMessage: String?
    var searchQuery = "" {
        didSet { handleSearchQueryChange() }
    }

    // MARK: - Initializers

    init(interactor: CatListInteractorProtocol) {
        self.interactor = interactor
    }

    // MARK: - Functions

    func image(for breed: CatBreed) -> CatImage? {
        breedImages[breed.id]
    }

    func loadBreeds() async {
        guard !isLoading else { return }
        isLoading = true
        defer { isLoading = false }
        errorMessage = nil

        do {
            let results = try await interactor.fetchBreedsWithImages()
            cachedBreeds = results.map(\.breed)
            breeds = cachedBreeds
            breedImages = results.reduce(into: [:]) { dict, result in
                if let image = result.image {
                    dict[result.breed.id] = image
                }
            }
        } catch is CancellationError {
            // Task cancelled by view disappearing — not an error
            errorMessage = nil
        } catch {
            handleError(error)
        }
    }

    func retry() {
        Task { [weak self] in
            await self?.loadBreeds()
        }
    }

    // MARK: - Private Functions

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
            breeds = cachedBreeds
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
