//
//  HeadlinesRowView.swift
//  Headlines
//
//  Created by Eduardo Dias on 31/08/2025.
//

import SwiftUI
import Storage

struct HeadlinesRowView: View {

    let article: Article
    
    let onTapHeadline: (Article) -> Void

    var body: some View {

        HStack(alignment: .top, spacing: 12) {

            HeadlinesRowViewAsyncImage(urlString: article.urlToImage)
                .padding(.top, 5)

            VStack(alignment: .leading, spacing: 4) {
                Text(article.title)
                    .font(.headline)
                    .lineLimit(2)

                Text(article.description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(2)

                VStack(alignment: .leading) {

                    Text("By \(article.authorName)")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    Text(article.sourceName)
                        .font(.caption)
                        .foregroundColor(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.blue)
                        .clipShape(Capsule())
                }
            }
            .padding(.vertical, 4)

            Spacer()
        }
        .padding(.horizontal)
        .onTapGesture {
            onTapHeadline(article)
        }
    }
}
