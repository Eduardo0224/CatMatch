//
//  CatDetailViewModel.swift
//  CatMatch
//
//  Created by Eduardo Andrade on 29/06/26.
//

import Foundation
import Observation

// MARK: - CatDetailViewModel

@Observable
final class CatDetailViewModel: CatDetailViewModelProtocol {

    // MARK: - Private Properties

    @ObservationIgnored
    private let interactor: CatDetailInteractorProtocol

    // MARK: - States

    private(set) var image: CatImage?
    private(set) var isLoadingImage = false
    private(set) var imageErrorMessage: String?
    private(set) var hasPreloadedImage = false

    // MARK: - Properties

    let breed: CatBreed

    var temperamentList: [String] {
        breed.temperament
            .split(separator: ",")
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }
    }

    var weightDisplay: String {
        "\(breed.weight.metric) \(L10n.CatDetail.weightSuffix)"
    }

    var originDisplay: String {
        breed.origin
    }

    var lifeSpanDisplay: String {
        "\(breed.lifeSpan) \(L10n.CatDetail.lifeSpanSuffix)"
    }

    // MARK: - Initializers

    init(breed: CatBreed, preloadedImage: CatImage? = nil, interactor: CatDetailInteractorProtocol = CatDetailInteractor()) {
        self.breed = breed
        self.interactor = interactor
        if let preloadedImage {
            self.image = preloadedImage
            self.hasPreloadedImage = true
        }
    }

    // MARK: - Functions

    func loadImage() async {
        guard !hasPreloadedImage else { return }
        guard let refID = breed.referenceImageID, !isLoadingImage else { return }
        isLoadingImage = true
        defer { isLoadingImage = false }
        imageErrorMessage = nil

        do {
            image = try await interactor.fetchImage(for: refID)
        } catch is CancellationError {
            imageErrorMessage = nil
        } catch {
            handleError(error)
        }
    }

    // MARK: - Private Functions

    private func handleError(_ error: Error) {
        if let networkError = error as? NetworkError {
            imageErrorMessage = networkError.userMessage
        } else {
            imageErrorMessage = L10n.Error.generic
        }
        print("[CatDetailViewModel] Image error: \(error)")
    }
}
