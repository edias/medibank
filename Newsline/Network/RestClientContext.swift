//
//  RestClientContext.swift
//  Newsline
//
//  Created by Eduardo Dias on 29/08/2025.
//

import RestClient

final class RestClientContext {

    static let shared = RestClientContext()

    let client: RestClient

    private init(environment: Environment = AppEnvironment.shared.environment) {
        let urlHostProvider = DefaultHostProvider(environment: environment)
        let apiKeyProvider = DefaultAPIKeyProvider(environment: environment)
        client = DefaultRestClient(urlHostProvider: urlHostProvider, apiKeyProvider: apiKeyProvider)
    }
}
