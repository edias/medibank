//
//  FavoritesView.swift
//  Favorites
//
//  Created by Eduardo Dias on 01/09/2025.
//

import SwiftUI

import CommonUI

struct FavoritesView: View {
    
    @StateObject
    private var viewModel: FavoritesViewModel

    init(viewModel: FavoritesViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    public var body: some View {

        NavigationView {

            VStack {

                if viewModel.savedArticles.isEmpty {
                    EmptyStateView(emptyState: viewModel.emptyState)

                } else {
                    List {
                        ForEach(viewModel.savedArticles, id: \.id) { article in
                            FavoriteRowView(article: article, onTapFavorite: viewModel.onTapFavorite)
                        }
                        .onDelete(perform: viewModel.deleteArticles)
                    }
                    .listStyle(PlainListStyle())
                }
            }
            .navigationTitle("Favorites")
            .onAppear {
                viewModel.loadFavorites()
            }
        }
    }
}

