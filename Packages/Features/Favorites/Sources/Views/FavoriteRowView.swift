//
//  FavoriteRowView.swift
//  Favorites
//
//  Created by Eduardo Dias on 01/09/2025.
//

import SwiftUI

import Storage

struct FavoriteRowView: View {
    
    let article: Article
    let onTapFavorite: (Article) -> Void
    
    var body: some View {

        VStack(alignment: .leading, spacing: 12) {

            HStack(alignment: .top, spacing: 16) {

                FavoriteRowAsyncImage(urlString: article.urlToImage)
                
                VStack(alignment: .leading, spacing: 8) {

                    Text(article.title)
                        .font(.title3)
                        .fontWeight(.semibold)
                        .lineLimit(3)
                    
                    Text(article.description)
                        .font(.body)
                        .foregroundColor(.secondary)
                        .lineLimit(3)
                    
                    Spacer()
                    
                    HStack {

                        VStack(alignment: .leading, spacing: 4) {

                            Text("By \(article.authorName)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            Text(article.sourceName)
                                .font(.caption)
                                .foregroundColor(.white)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 6)
                                .background(Color.purple)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
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
