//
//  FavoritesViewModel+Factory.swift
//  Favorites
//
//  Created by Eduardo Dias on 01/09/2025.
//

import CommonUI

extension FavoritesViewModel {
    enum StateFactory {
        static func makeEmptyFavoritesState() -> EmptyState {
            EmptyState(
                iconName: "heart",
                title: "No Favorites Yet",
                description: "Save articles from Headlines to see them here"
            )
        }
    }
}
