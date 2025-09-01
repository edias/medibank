//
//  FavoriteRowView.swift
//  Favorites
//
//  Created by Eduardo Dias on 01/09/2025.
//

import SwiftUI

import CommonUI
import Storage

struct FavoriteRowView: View {
    
    let article: Article
    let onTapFavorite: (Article) -> Void
    
    var body: some View {

        VStack(alignment: .leading, spacing: DesignSystem.metrics.large) {

            HStack(alignment: .top, spacing: DesignSystem.metrics.cardPadding) {

                FavoriteRowAsyncImage(urlString: article.urlToImage)
                
                VStack(alignment: .leading, spacing: DesignSystem.metrics.medium) {

                    Text(article.title)
                        .font(DesignSystem.typography.title3)
                        .fontWeight(DesignSystem.typography.semibold)
                        .lineLimit(DesignSystem.typography.descriptionLines)

                    Text(article.description)
                        .font(DesignSystem.typography.body)
                        .foregroundColor(DesignSystem.colors.placeholder)
                        .lineLimit(DesignSystem.typography.descriptionLines)

                    Spacer()
                    
                    HStack {

                        VStack(alignment: .leading, spacing: DesignSystem.metrics.small) {

                            Text("By \(article.authorName)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            Text(article.sourceName)
                                .font(DesignSystem.typography.caption)
                                .foregroundColor(DesignSystem.colors.onBrand)
                                .padding(.horizontal, DesignSystem.metrics.iconPadding)
                                .padding(.vertical, DesignSystem.metrics.badgePadding)
                                .background(DesignSystem.colors.secondary)
                                .clipShape(RoundedRectangle(cornerRadius: DesignSystem.metrics.cornerMedium))
                        }
                    }
                }
            }
        }
        .padding(.vertical, 16)
        .padding(.horizontal, 16)
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .padding(.vertical, 4)
        .onTapGesture {
            onTapFavorite(article)
        }
    }
}
