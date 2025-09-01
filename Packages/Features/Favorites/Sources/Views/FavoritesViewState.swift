//
//  FavoritesViewState.swift
//  Favorites
//
//  Created by Eduardo Dias on 01/09/2025.
//

import CommonUI
import Storage

enum FavoritesViewState {
    case loading
    case loaded([Article])
    case empty(EmptyState)
}
