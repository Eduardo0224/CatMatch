//
//  CatListRowView.swift
//  CatMatch
//
//  Created by Eduardo Andrade on 29/06/26.
//

import SwiftUI
import CatUI

// MARK: - CatListRowView

struct CatListRowView: View {

    // MARK: - Properties

    let breed: CatBreed
    let image: CatImage?

    // MARK: - Body

    var body: some View {
        CatCardView {
            HStack(spacing: CatSpacing.spacing12) {
                CatImageView(url: image?.url)
                    .frame(width: 120, height: 120)
                    .clipShape(RoundedRectangle(cornerRadius: CatRadius.radius12))

                VStack(alignment: .leading, spacing: CatSpacing.spacing4) {
                    Text(breed.name)
                        .font(.catHeadline)
                        .foregroundStyle(Color.catTextPrimary)
                        .lineLimit(1)

                    Text(breed.temperament)
                        .font(.catCaption)
                        .foregroundStyle(Color.catTextSecondary)
                        .lineLimit(2)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .contentShape(Rectangle())
    }
}

// MARK: - Preview

#Preview("Default") {
    CatListRowView(
        breed: MockCatListInteractor.mockBreeds[0],
        image: MockCatListInteractor.mockImage
    )
    .padding()
}

#Preview("Dark Mode") {
    CatListRowView(
        breed: MockCatListInteractor.mockBreeds[1],
        image: MockCatListInteractor.mockImage
    )
    .padding()
    .preferredColorScheme(.dark)
}

#Preview("No Image") {
    CatListRowView(
        breed: MockCatListInteractor.mockBreeds[2],
        image: nil
    )
    .padding()
}

#Preview("No Image - Dark Mode") {
    CatListRowView(
        breed: MockCatListInteractor.mockBreeds[2],
        image: nil
    )
    .padding()
    .preferredColorScheme(.dark)
}
