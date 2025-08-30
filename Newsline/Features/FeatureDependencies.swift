//
//  FeatureDependecnies.swift
//  Newsline
//
//  Created by Eduardo Dias on 30/08/2025.
//

import RestClient
import SourceSelection

final class FeatureDependencies {

    private let restClient: RestClient

    lazy var sourceSelection: SourceSelectionDependencies = DefaultSourceSelectionDependencies(
        restClient: restClient,
    )

    init(restClient: RestClient = RestClientContext.shared.client) {
        self.restClient = restClient
    }
}
