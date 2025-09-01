//
//  HeadlinesRowViewAsyncImage.swift
//  Headlines
//
//  Created by Eduardo Dias on 31/08/2025.
//

import SwiftUI

import CommonUI

struct HeadlinesRowViewAsyncImage: View {

    let urlString: String

    var body: some View {

        AsyncImage(url: URL(string: urlString)) { phase in

            switch phase {

            case let .success(image):
                image.resizable()
                    .scaledToFill()

            case .failure:
                Image(systemName: "photo")
                    .foregroundColor(DesignSystem.colors.placeholder)
                    .scaledToFit()
                    .padding(10)

            case .empty:
                ProgressView()

            @unknown default:
                EmptyView()
            }
        }
        .frame(width: DesignSystem.metrics.thumbnailSmall, height: DesignSystem.metrics.thumbnailSmall)
        .background(DesignSystem.colors.placeholderBackground)
        .clipShape(RoundedRectangle(cornerRadius: DesignSystem.metrics.cornerSmall))
    }
}
