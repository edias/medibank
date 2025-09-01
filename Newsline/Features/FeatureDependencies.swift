//
//  FeatureDependencies.swift
//  Newsline
//
//  Created by Eduardo Dias on 30/08/2025.
//

import CommonWeb
import Favorites
import Headlines
import SourceSelection

import RestClient
import Storage

import Foundation

final class FeatureDependencies {

    private let restClient: RestClient

    private let selectionStorage: SelectionStorage
    private let articlesStorage: ArticlesStorage

    private let onTapArticle: @MainActor (Article) -> Void

    lazy var commonWeb: CommonWebDependencies = DefaultCommonWebDependencies(
        articlesStorage: articlesStorage
    )

    lazy var headlines: HeadlinesDependencies = DefaultHeadlinesDependencies(
        restClient: restClient,
        selectionStorage: selectionStorage,
        onTapHeadline: onTapArticle
    )

    lazy var sourceSelection: SourceSelectionDependencies = DefaultSourceSelectionDependencies(
        restClient: restClient,
        selectionStorage: selectionStorage
    )

    lazy var favorites: FavoritesDependencies = DefaultFavoritesDependencies(
        articlesStorage: articlesStorage,
        onTapFavorite: onTapArticle
    )

    init(
        restClient: RestClient = AppContext.shared.restClient,
        selectionStorage: SelectionStorage = AppContext.shared.selectionStorage,
        articlesStorage: ArticlesStorage = AppContext.shared.articlesStorage,
        onTapArticle: @escaping @MainActor (Article) -> Void
    ) {
        self.restClient = restClient
        self.selectionStorage = selectionStorage
        self.articlesStorage = articlesStorage
        self.onTapArticle = onTapArticle
    }
}
