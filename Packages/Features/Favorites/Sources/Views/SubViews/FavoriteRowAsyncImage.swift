//
//  FavoriteRowAsyncImage.swift
//  Favorites
//
//  Created by Eduardo Dias on 01/09/2025.
//

import SwiftUI

import CommonUI

struct FavoriteRowAsyncImage: View {

    let urlString: String

    var body: some View {

        AsyncImage(url: URL(string: urlString)) { phase in

            switch phase {

            case let .success(image):
                image
                    .resizable()
                    .scaledToFill()

            case .failure:
                Image(systemName: "photo.fill")
                    .foregroundColor(DesignSystem.colors.placeholder)
                    .scaledToFit()
                    .padding(DesignSystem.metrics.cardPadding)

            case .empty:
                ProgressView()
                    .tint(DesignSystem.colors.secondary)

            @unknown default:
                EmptyView()
            }
        }
        .frame(width: DesignSystem.metrics.thumbnailMedium, height: DesignSystem.metrics.thumbnailMedium)
        .background(DesignSystem.colors.placeholderBackground)
        .clipShape(RoundedRectangle(cornerRadius: DesignSystem.metrics.cornerMedium))
    }
}
