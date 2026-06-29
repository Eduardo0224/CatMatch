//
//  CatDetailView.swift
//  CatMatch
//
//  Created by Eduardo Andrade on 29/06/26.
//

import SwiftUI
import CatUI

// MARK: - CatDetailView

struct CatDetailView: View {

    // MARK: - Private Properties

    // MARK: - States

    @State private var viewModel: CatDetailViewModel

    // MARK: - Body

    var body: some View {
        ZStack(alignment: .top) {
            heroBackground
                .ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: CatSpacing.spacing24) {
                    catImageCard
                    breedInfo
                    temperamentContent
                    detailsContent
                }
                .padding(.horizontal, CatSpacing.spacing16)
                .padding(.bottom, CatSpacing.spacing24)
            }
        }
        .task { await viewModel.loadImage() }
    }

    // MARK: - Initializers

    init(
        breed: CatBreed,
        preloadedImage: CatImage? = nil,
        interactor: CatDetailInteractorProtocol = CatDetailInteractor()
    ) {
        _viewModel = State(initialValue: CatDetailViewModel(
            breed: breed,
            preloadedImage: preloadedImage,
            interactor: interactor
        ))
    }

    // MARK: - Private Views

    /// Decorative blurred background — fixed height, purely for ambiance (Inku pattern).
    /// GeometryReader measures the exact available width so the image can never push
    /// the ZStack wider than the screen, breaking Reason #10 (no image→layout dependency).
    private var heroBackground: some View {
        GeometryReader { proxy in
            ZStack(alignment: .bottom) {
                imageBackgroundContent
                    .frame(width: proxy.size.width, height: 350)
                    .clipped()

                Rectangle()
                    .fill(.thinMaterial)
                    .frame(width: proxy.size.width, height: 350)

                LinearGradient(
                    gradient: Gradient(colors: [.clear, Color.catSurfacePrimary]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .frame(height: 100)
            }
        }
        .frame(height: 350)
    }

    @ViewBuilder
    private var imageBackgroundContent: some View {
        if let image = viewModel.image {
            CatImageView(url: image.url)
        } else {
            fallbackBackground
        }
    }

    private var fallbackBackground: some View {
        Rectangle()
            .fill(Color.catSurfaceSecondary)
            .overlay {
                Image(systemName: "cat")
                    .font(.largeTitle)
                    .foregroundStyle(Color.catTextSecondary)
            }
    }

    /// Actual cat image inside ScrollView — fixed frame guarantees consistent sizing (Inku pattern).
    @ViewBuilder
    private var catImageCard: some View {
        if viewModel.isLoadingImage && viewModel.image == nil {
            Rectangle()
                .fill(Color.catSurfaceSecondary)
                .frame(maxWidth: .infinity)
                .frame(height: 280)
                .clipShape(RoundedRectangle(cornerRadius: CatRadius.radius16))
                .shimmer()
        } else if let image = viewModel.image {
            GeometryReader { proxy in
                CatImageView(url: image.url)
                    .frame(width: proxy.size.width, height: 280)
                    .clipped()
                    .clipShape(RoundedRectangle(cornerRadius: CatRadius.radius16))
            }
            .frame(height: 280)
            .shadow(color: .black.opacity(0.15), radius: 10, y: 5)
        } else {
            imageFallbackCard
        }

        if let error = viewModel.imageErrorMessage {
            HStack(spacing: CatSpacing.spacing8) {
                Image(systemName: "exclamationmark.triangle")
                    .font(.catCaption)
                Text(error)
                    .font(.catCaption)
            }
            .foregroundStyle(Color.catTextSecondary)
            .frame(maxWidth: .infinity, alignment: .center)
            .padding(CatSpacing.spacing12)
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: CatRadius.radius12))
        }
    }

    private var imageFallbackCard: some View {
        Rectangle()
            .fill(Color.catSurfaceSecondary)
            .frame(maxWidth: .infinity)
            .frame(height: 280)
            .clipShape(RoundedRectangle(cornerRadius: CatRadius.radius16))
            .overlay {
                Image(systemName: "cat")
                    .font(.largeTitle)
                    .foregroundStyle(Color.catTextSecondary)
            }
    }

    private var breedInfo: some View {
        VStack(alignment: .leading, spacing: CatSpacing.spacing8) {
            Text(viewModel.breed.name)
                .font(.catDisplay)
                .foregroundStyle(Color.catTextPrimary)

            Text(viewModel.breed.description)
                .font(.catBody)
                .foregroundStyle(Color.catTextSecondary)
        }
        .padding(CatSpacing.spacing24)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.catSurfacePrimary)
        .clipShape(RoundedRectangle(cornerRadius: CatRadius.radius16))
    }

    private var temperamentContent: some View {
        VStack(alignment: .leading, spacing: CatSpacing.spacing8) {
            Text(L10n.CatDetail.temperament)
                .font(.catHeadline)
                .foregroundStyle(Color.catTextPrimary)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: CatSpacing.spacing8) {
                    ForEach(viewModel.temperamentList, id: \.self) { trait in
                        CatBadgeView(trait, style: .accent)
                    }
                }
            }
            .contentMargins(CatSpacing.spacing4, for: .scrollContent)
        }
        .padding(CatSpacing.spacing24)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.catSurfacePrimary)
        .clipShape(RoundedRectangle(cornerRadius: CatRadius.radius16))
    }

    private var detailsContent: some View {
        VStack(spacing: 0) {
            detailRow(label: L10n.CatDetail.origin, value: viewModel.originDisplay)
            Divider()
                .padding(.vertical, CatSpacing.spacing12)
            detailRow(label: L10n.CatDetail.lifeSpan, value: viewModel.lifeSpanDisplay)
            Divider()
                .padding(.vertical, CatSpacing.spacing12)
            detailRow(label: L10n.CatDetail.weight, value: viewModel.weightDisplay)
        }
        .padding(CatSpacing.spacing24)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.catSurfacePrimary)
        .clipShape(RoundedRectangle(cornerRadius: CatRadius.radius16))
    }

    // MARK: - Private Functions

    private func detailRow(label: String, value: String) -> some View {
        HStack {
            Text(label)
                .font(.catBody)
                .foregroundStyle(Color.catTextSecondary)
            Spacer()
            Text(value)
                .font(.catBody)
                .foregroundStyle(Color.catTextPrimary)
        }
    }
}

// MARK: - Preview

#Preview("CatDetail - With Image") {
    NavigationStack {
        CatDetailView(
            breed: MockCatDetailInteractor.mockBreed,
            interactor: MockCatDetailInteractor()
        )
    }
}

#Preview("CatDetail - Dark Mode") {
    NavigationStack {
        CatDetailView(
            breed: MockCatDetailInteractor.mockBreed,
            interactor: MockCatDetailInteractor()
        )
    }
    .preferredColorScheme(.dark)
}

#Preview("CatDetail - No Image") {
    NavigationStack {
        CatDetailView(
            breed: MockCatDetailInteractor.mockBreed,
            interactor: MockCatDetailInteractor(
                fetchImageResult: .success(nil)
            )
        )
    }
}

#Preview("CatDetail - Image Error") {
    NavigationStack {
        CatDetailView(
            breed: MockCatDetailInteractor.mockBreed,
            interactor: MockCatDetailInteractor(
                fetchImageResult: .failure(NetworkError.rateLimited)
            )
        )
    }
}
