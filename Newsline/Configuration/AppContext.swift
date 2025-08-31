//
//  RestClientContext.swift
//  Newsline
//
//  Created by Eduardo Dias on 29/08/2025.
//

import RestClient
import Storage

final class AppContext {

    static let shared = AppContext()

    let restClient: RestClient

    let storage: SelectionStorage

    private init(environment: Environment = AppEnvironment.shared.environment) {
        restClient = Self.makeRestClient(environment)
        storage = DefaultSelectionStorage()
    }

    private static func makeRestClient(_ environment: Environment) -> RestClient {
        let urlHostProvider = DefaultHostProvider(environment: environment)
        let apiKeyProvider = DefaultAPIKeyProvider(environment: environment)
        return DefaultRestClient(urlHostProvider: urlHostProvider, apiKeyProvider: apiKeyProvider)
    }
}
