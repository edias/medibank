//
//  HeadlinesRowView.swift
//  Headlines
//
//  Created by Eduardo Dias on 31/08/2025.
//

import SwiftUI
import Storage
import CommonUI

struct HeadlinesRowView: View {

    let article: Article
    
    let onTapHeadline: (Article) -> Void

    var body: some View {

        HStack(alignment: .top, spacing: DesignSystem.metrics.large) {

            HeadlinesRowViewAsyncImage(urlString: article.urlToImage)
                .padding(.top, DesignSystem.metrics.small)

            VStack(alignment: .leading, spacing: DesignSystem.metrics.small) {

                Text(article.title)
                    .font(DesignSystem.typography.headline)
                    .lineLimit(DesignSystem.typography.titleLines)

                Text(article.description)
                    .font(DesignSystem.typography.subheadline)
                    .foregroundColor(DesignSystem.colors.secondaryText)
                    .lineLimit(DesignSystem.typography.titleLines)

                VStack(alignment: .leading) {

                    Text("By \(article.authorName)")
                        .font(DesignSystem.typography.caption)
                        .foregroundColor(.secondary)

                    Text(article.sourceName)
                        .font(DesignSystem.typography.caption)
                        .foregroundColor(DesignSystem.colors.onBrand)
                        .padding(.horizontal, DesignSystem.metrics.medium)
                        .padding(.vertical, DesignSystem.metrics.small)
                        .background(DesignSystem.colors.primary)
                        .clipShape(Capsule())
                }
            }
            .padding(.vertical, DesignSystem.metrics.small)

            Spacer()
        }
        .padding(.horizontal)
        .onTapGesture {
            onTapHeadline(article)
        }
    }
}
