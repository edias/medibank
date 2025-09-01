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

    var body: some View {

        NavigationView {

            VStack {

                switch viewModel.viewState {

                case .loading:
                    ProgressView(viewModel.loadingText)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .foregroundColor(DesignSystem.colors.secondaryText)

                case let .loaded(articles):
                    List {
                        ForEach(articles, id: \.id) { article in
                            FavoriteRowView(article: article, onTapFavorite: viewModel.onTapFavorite)
                        }
                        .onDelete(perform: viewModel.deleteArticles)
                    }
                    .listStyle(PlainListStyle())

                case let .empty(emptyState):
                    EmptyStateView(emptyState)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
            .navigationTitle(viewModel.title)
            .onAppear {
                viewModel.loadFavorites()
            }
        }
    }
}
