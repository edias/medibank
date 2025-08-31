//
//  HeadlinesRowViewAsyncImage.swift
//  Headlines
//
//  Created by Eduardo Dias on 31/08/2025.
//

import SwiftUI

struct HeadlinesRowViewAsyncImage: View {

    let urlString: String

    var body: some View {
        AsyncImage(url: URL(string: urlString)) { phase in
            switch phase {
            case .success(let image):
                image
                    .resizable()
                    .scaledToFill()
            case .failure(_):
                Image(systemName: "photo")
                    .foregroundColor(.gray)
                    .scaledToFit()
                    .padding(10)
            case .empty:
                ProgressView()
            @unknown default:
                EmptyView()
            }
        }
        .frame(width: 60, height: 60)
        .background(Color.gray.opacity(0.2))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}
