//
//  SourcesNetworkServices.swift
//  SourceSelection
//
//  Created by Eduardo Dias on 30/08/2025.
//

import RestClient

protocol SourcesNetworkServices: Sendable {
    func fetchSources() async throws -> [Source]
}

actor DefaultSourcesNetworkServices: SourcesNetworkServices {

    private let restClient: RestClient

    init(restClient: RestClient) {
        self.restClient = restClient
    }

    @MainActor
    func fetchSources() async throws -> [Source] {
        let endpoint = EndpointBuilder<EmptyData, SourcesResponse>.get()
            .withPath("/v2/top-headlines/sources")
            .withQuery("language", value: "en")
            .build()

        return try await restClient.executeRequest(endpoint.makeRequest()).sources
    }
}
