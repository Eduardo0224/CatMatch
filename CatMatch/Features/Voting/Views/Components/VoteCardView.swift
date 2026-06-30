//
//  VoteCardView.swift
//  CatMatch
//
//  Created by Eduardo Andrade on 29/06/26.
//

import SwiftUI
import CatUI

// MARK: - VoteCardView

struct VoteCardView: View {

    // MARK: - Properties

    let breed: CatBreed?
    let imageURL: URL?
    let cardWidth: CGFloat

    // MARK: - Body

    var body: some View {
        VStack(spacing: 0) {
            CatImageView(url: imageURL)
                .frame(width: cardWidth, height: cardWidth * 1.4)
                .clipped()

            if let breed {
                Text(breed.name)
                    .font(.catTitle)
                    .foregroundStyle(Color.catTextPrimary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, CatSpacing.spacing16)
                    .padding(.vertical, CatSpacing.spacing16)
                    .background(Color.catSurfacePrimary)
            }
        }
        .background(Color.catSurfacePrimary)
        .clipShape(RoundedRectangle(cornerRadius: CatRadius.radius16))
        .shadow(color: .black.opacity(0.18), radius: 14, y: 6)
    }
}

// MARK: - Preview

#Preview("VoteCard - With Image") {
    VoteCardView(
        breed: MockBreedStore.mockBreed,
        imageURL: MockBreedStore.mockImage.url,
        cardWidth: 300
    )
    .padding()
}

#Preview("VoteCard - No Image") {
    VoteCardView(
        breed: MockBreedStore.mockBreed,
        imageURL: nil,
        cardWidth: 300
    )
    .padding()
}

#Preview("VoteCard - Dark Mode") {
    VoteCardView(
        breed: MockBreedStore.mockBreed,
        imageURL: MockBreedStore.mockImage.url,
        cardWidth: 300
    )
    .padding()
    .preferredColorScheme(.dark)
}

#Preview("VoteCard - No Image, Dark Mode") {
    VoteCardView(
        breed: MockBreedStore.mockBreed,
        imageURL: nil,
        cardWidth: 300
    )
    .padding()
    .preferredColorScheme(.dark)
}
