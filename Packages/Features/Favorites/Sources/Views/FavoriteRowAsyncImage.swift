//
//  FavoriteRowAsyncImage.swift
//  Favorites
//
//  Created by Eduardo Dias on 01/09/2025.
//

import SwiftUI

struct FavoriteRowAsyncImage: View {
    
    let urlString: String
    
    var body: some View {

        AsyncImage(url: URL(string: urlString)) { phase in

            switch phase {

            case .success(let image):
                image
                    .resizable()
                    .scaledToFill()

            case .failure(_):
                Image(systemName: "photo.fill")
                    .foregroundColor(.gray)
                    .scaledToFit()
                    .padding(15)

            case .empty:
                ProgressView()
                    .tint(.purple)
                
            @unknown default:
                EmptyView()
            }
        }
        .frame(width: 80, height: 80)
        .background(Color.gray.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}
