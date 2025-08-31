//
//  FavoriteButton.swift
//  CommonWeb
//
//  Created by Eduardo Dias on 01/09/2025.
//

import SwiftUI
import Storage

struct FavoriteButton: View {

    @EnvironmentObject
    private var storage: ObservableArticlesStorage

    let article: Article

    var body: some View {
        ZStack {
            Circle()
                .fill(Color.white)
                .frame(width: 50, height: 50)

            Circle()
                .fill(Color.blue)
                .frame(width: 40, height: 40)

            Image(systemName: storage.isArticleSaved(article.url) ? "star.fill" : "star")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.white)
        }
        .onTapGesture {
            storage.toggleArticle(for: article)
        }
    }
}
