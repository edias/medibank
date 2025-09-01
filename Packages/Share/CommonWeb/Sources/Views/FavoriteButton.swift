//
//  FavoriteButton.swift
//  CommonWeb
//
//  Created by Eduardo Dias on 01/09/2025.
//

import Storage
import SwiftUI

import CommonUI

struct FavoriteButton: View {

    @EnvironmentObject
    private var storage: ObservableArticlesStorage

    let article: Article

    var body: some View {

        ZStack {

            Circle()
                .fill(DesignSystem.colors.onBrand)
                .frame(width: DesignSystem.metrics.buttonSize, height: DesignSystem.metrics.buttonSize)

            Circle()
                .fill(DesignSystem.colors.error)
                .frame(width: DesignSystem.metrics.iconSize, height: DesignSystem.metrics.iconSize)

            Image(systemName: storage.isArticleSaved(article.url) ? "heart.fill" : "heart")
                .font(DesignSystem.typography.buttonText)
                .foregroundColor(.white)
        }
        .onTapGesture {
            storage.toggleArticle(for: article)
        }
    }
}
