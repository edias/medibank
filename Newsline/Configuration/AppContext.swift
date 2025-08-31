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

    let selectionStorage: SelectionStorage

    let articlesStorage: ArticlesStorage

    private init(environment: Environment = AppEnvironment.shared.environment) {
        restClient = Self.makeRestClient(environment)
        selectionStorage = DefaultSelectionStorage()
        articlesStorage = DefaultArticlesStorage()
    }

    private static func makeRestClient(_ environment: Environment) -> RestClient {
        let urlHostProvider = DefaultHostProvider(environment: environment)
        let apiKeyProvider = DefaultAPIKeyProvider(environment: environment)
        return DefaultRestClient(urlHostProvider: urlHostProvider, apiKeyProvider: apiKeyProvider)
    }
}
