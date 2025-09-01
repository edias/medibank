//
//  EmptyFavoritesView.swift
//  Favorites
//
//  Created by Eduardo Dias on 01/09/2025.
//

import SwiftUI

struct EmptyFavoritesView: View {

    var body: some View {

        VStack(spacing: 16) {
            
            Image(systemName: "heart")
                .font(.system(size: 50))
                .foregroundColor(.secondary)
            
            Text("No Favorites Yet")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("Save articles from Headlines to see them here")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(32)
    }
}
