//
//  File.swift
//  Newsline
//
//  Created by Eduardo Dias on 01/09/2025.
//

import SwiftUI

struct FavoriteButton: View {

    let url: URL

    @State private var isFavorite = false

    var body: some View {
        ZStack {
            Circle()
                .fill(Color.white)
                .frame(width: 50, height: 50)

            Circle()
                .fill(Color.blue)
                .frame(width: 40, height: 40)

            Image(systemName: isFavorite ? "star.fill" : "star")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.white)
        }
        .onTapGesture {
            isFavorite.toggle()
        }
    }
}
