//
//  DefaultFavoritesDependencies.swift
//  Newsline
//
//  Created by Eduardo Dias on 30/08/2025.
//

import Favorites
import Storage

struct DefaultFavoritesDependencies: FavoritesDependencies {
    let articlesStorage: ArticlesStorage
    let onTapFavorite: @MainActor (Article) -> Void
}
