//
//  HeadlinesNetworkServices.swift
//  Headlines
//
//  Created by Eduardo Dias on 31/08/2025.
//

import RestClient

protocol HeadlinesNetworkServices {
    @MainActor
    func fetchHeadlines(bySources sources: [String]) async throws -> [Article]
}

class DefaultHeadlinesNetworkServices: HeadlinesNetworkServices {

    private let restClient: RestClient

    init(restClient: RestClient) {
        self.restClient = restClient
    }

    func fetchHeadlines(bySources sources: [String]) async throws -> [Article] {

        let endpoint = EndpointBuilder<EmptyData, ArticlesResponse>.get()
            .withPath("/v2/top-headlines")
            .withQuery("sources", values: sources)
            .build()

        return try await restClient.executeRequest(endpoint.makeRequest()).articles
    }
}
