//
//  FeatureDependecnies.swift
//  Newsline
//
//  Created by Eduardo Dias on 30/08/2025.
//

import Headlines
import SourceSelection

import RestClient
import Storage

import Foundation

final class FeatureDependencies {

    private let restClient: RestClient
    private let selectionStorage: SelectionStorage
    private let onTapHeadline: @MainActor (URL) -> Void

    lazy var headlines: HeadlinesDependencies = DefaultHeadlinesDependencies(
        restClient: restClient,
        selectionStorage: selectionStorage,
        onTapHeadline: onTapHeadline
    )

    lazy var sourceSelection: SourceSelectionDependencies = DefaultSourceSelectionDependencies(
        restClient: restClient,
        selectionStorage: selectionStorage
    )

    init(
        restClient: RestClient = AppContext.shared.restClient,
        selectionStorage: SelectionStorage = AppContext.shared.storage,
        onTapHeadline: @escaping @MainActor (URL) -> Void
    ) {
        self.restClient = restClient
        self.selectionStorage = selectionStorage
        self.onTapHeadline = onTapHeadline
    }
}
