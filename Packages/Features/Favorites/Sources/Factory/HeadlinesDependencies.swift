//
//  HeadlinesDependencies.swift
//  Favorites
//
//  Created by Eduardo Dias on 01/09/2025.
//

import SwiftUI

import Storage

public protocol FavoritesDependencies {
    var articlesStorage: ArticlesStorage { get }
    var onTapFavorite: @MainActor (Article) -> Void { get }
}

public protocol FeatureFactory {
    associatedtype RootView: View
    func makeRootView() -> RootView
}

public struct FavoritesFactory: @preconcurrency FeatureFactory {

    private let dependencies: FavoritesDependencies

    public init(_ dependencies: FavoritesDependencies) {
        self.dependencies = dependencies
    }

    @MainActor
    public func makeRootView() -> some View {
        let viewModel = FavoritesViewModel(articlesStorage: dependencies.articlesStorage, onTapFavorite: dependencies.onTapFavorite)
        return FavoritesView(viewModel: viewModel)
    }
}
