//
//  FeatureDependecnies.swift
//  Newsline
//
//  Created by Eduardo Dias on 30/08/2025.
//

import RestClient
import SourceSelection

import Storage

final class FeatureDependencies {

    private let restClient: RestClient

    private let selectionStorage: SelectionStorage

    lazy var sourceSelection: SourceSelectionDependencies = DefaultSourceSelectionDependencies(
        restClient: restClient,
        selectionStorage: selectionStorage
    )

    init(restClient: RestClient = AppContext.shared.restClient, selectionStorage: SelectionStorage = AppContext.shared.storage) {
        self.restClient = restClient
        self.selectionStorage = selectionStorage
    }
}
