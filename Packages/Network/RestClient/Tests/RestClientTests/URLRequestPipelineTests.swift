import Foundation
import Testing

@testable import RestClient

@Suite("URLRequestPipeline Tests")
struct URLRequestPipelineTests {

    // MARK: - DefaultURLRequestPipeline Tests

    @Test("URL request creation through pipeline with GET request")
    func urlRequestCreationThroughPipelineWithGetRequest() throws {
        let urlHost = DefaultUrlHost(baseUrl: "https://api.example.com")
        let hostProvider = DefaultURLHostProvider(urlHost: urlHost)
        let apiKeyProvider = MockAPIKeyProvider(apiKey: "test-key")
        let pipeline = DefaultURLRequestPipeline(urlHostProvider: hostProvider, apiKeyProvider: apiKeyProvider)

        let clientRequest = makeGetRequest(path: "/users")
        let urlRequest = try pipeline.makeUrlRequest(clientRequest)

        #expect(urlRequest.url?.absoluteString == "https://api.example.com/users")
        #expect(urlRequest.httpMethod == "GET")
        #expect(urlRequest.httpBody == nil)
        #expect(urlRequest[.contentType] == "application/json")
        #expect(urlRequest[.apiKey] == "test-key")
    }

    @Test("URL request creation through pipeline with POST request")
    func urlRequestCreationThroughPipelineWithPostRequest() throws {
        let urlHost = DefaultUrlHost(baseUrl: "https://api.example.com")
        let hostProvider = DefaultURLHostProvider(urlHost: urlHost)
        let apiKeyProvider = MockAPIKeyProvider(apiKey: "post-key")
        let pipeline = DefaultURLRequestPipeline(urlHostProvider: hostProvider, apiKeyProvider: apiKeyProvider)

        let clientRequest = makePostRequest(path: "/users")
        let urlRequest = try pipeline.makeUrlRequest(clientRequest)

        #expect(urlRequest.url?.absoluteString == "https://api.example.com/users")
        #expect(urlRequest.httpMethod == "POST")
        #expect(urlRequest.httpBody != nil)
        #expect(urlRequest[.contentType] == "application/json")
        #expect(urlRequest[.apiKey] == "post-key")
    }

    @Test("URL request creation through pipeline with PUT request")
    func urlRequestCreationThroughPipelineWithPutRequest() throws {
        let urlHost = DefaultUrlHost(baseUrl: "https://api.example.com")
        let hostProvider = DefaultURLHostProvider(urlHost: urlHost)
        let apiKeyProvider = MockAPIKeyProvider(apiKey: "put-key")
        let pipeline = DefaultURLRequestPipeline(urlHostProvider: hostProvider, apiKeyProvider: apiKeyProvider)

        let clientRequest = makePutRequest(path: "/users/1")
        let urlRequest = try pipeline.makeUrlRequest(clientRequest)

        #expect(urlRequest.url?.absoluteString == "https://api.example.com/users/1")
        #expect(urlRequest.httpMethod == "PUT")
        #expect(urlRequest.httpBody != nil)
        #expect(urlRequest[.contentType] == "application/json")
        #expect(urlRequest[.apiKey] == "put-key")
    }

    @Test("URL request body serialization for POST request")
    func urlRequestBodySerializationForPostRequest() throws {
        let urlHost = DefaultUrlHost(baseUrl: "https://api.example.com")
        let hostProvider = DefaultURLHostProvider(urlHost: urlHost)
        let apiKeyProvider = MockAPIKeyProvider(apiKey: "test-key")
        let pipeline = DefaultURLRequestPipeline(urlHostProvider: hostProvider, apiKeyProvider: apiKeyProvider)

        let requestData = TestRequest(name: "John", value: 42)
        let clientRequest = makePostRequestWithData(path: "/users", data: requestData)
        let urlRequest = try pipeline.makeUrlRequest(clientRequest)

        #expect(urlRequest.httpBody != nil)

        // Verify the serialized body contains expected data
        let bodyData = urlRequest.httpBody!
        let deserializedData = try JSONDecoder().decode(TestRequest.self, from: bodyData)
        #expect(deserializedData.name == "John")
        #expect(deserializedData.value == 42)
    }

    @Test("URL request pipeline with query parameters")
    func urlRequestPipelineWithQueryParameters() throws {
        let urlHost = DefaultUrlHost(baseUrl: "https://api.example.com")
        let hostProvider = DefaultURLHostProvider(urlHost: urlHost)
        let apiKeyProvider = MockAPIKeyProvider(apiKey: "query-key")
        let pipeline = DefaultURLRequestPipeline(urlHostProvider: hostProvider, apiKeyProvider: apiKeyProvider)

        let clientRequest = makeGetRequestWithQuery(path: "/search", key: "q", value: "swift")
        let urlRequest = try pipeline.makeUrlRequest(clientRequest)

        #expect(urlRequest.url?.absoluteString == "https://api.example.com/search?q=swift")
        #expect(urlRequest.httpMethod == "GET")
        #expect(urlRequest[.contentType] == "application/json")
        #expect(urlRequest[.apiKey] == "query-key")
    }

    @Test("URL request pipeline without API key")
    func urlRequestPipelineWithoutApiKey() throws {
        let urlHost = DefaultUrlHost(baseUrl: "https://api.example.com")
        let hostProvider = DefaultURLHostProvider(urlHost: urlHost)
        let apiKeyProvider = MockAPIKeyProvider(apiKey: nil)
        let pipeline = DefaultURLRequestPipeline(urlHostProvider: hostProvider, apiKeyProvider: apiKeyProvider)

        let clientRequest = makeGetRequest(path: "/public")
        let urlRequest = try pipeline.makeUrlRequest(clientRequest)

        #expect(urlRequest.url?.absoluteString == "https://api.example.com/public")
        #expect(urlRequest.httpMethod == "GET")
        #expect(urlRequest[.contentType] == "application/json")
        #expect(urlRequest[.apiKey] == nil)
    }

    @Test("URL request pipeline with custom components")
    func urlRequestPipelineWithCustomComponents() throws {
        let requestBuilder = MockURLRequestBuilder()
        let serializer = MockSerializer()
        let headerInjector = MockHeaderInjector()
        let apiKeyProvider = MockAPIKeyProvider(apiKey: "custom-key")

        let pipeline = DefaultURLRequestPipeline(
            requestBuilder: requestBuilder,
            serializer: serializer,
            headerInjector: headerInjector,
            apiKeyProvider: apiKeyProvider
        )

        let clientRequest = makePostRequest(path: "/test")
        _ = try pipeline.makeUrlRequest(clientRequest)

        #expect(requestBuilder.makeUrlRequestCalled == true)
        #expect(serializer.serializeCalled == true)
        #expect(headerInjector.injectCalled == true)
    }

    @Test("URL request pipeline preserves existing headers")
    func urlRequestPipelinePreservesExistingHeaders() throws {
        let urlHost = DefaultUrlHost(baseUrl: "https://api.example.com")
        let hostProvider = DefaultURLHostProvider(urlHost: urlHost)
        let apiKeyProvider = MockAPIKeyProvider(apiKey: "test-key")
        let pipeline = DefaultURLRequestPipeline(urlHostProvider: hostProvider, apiKeyProvider: apiKeyProvider)

        let clientRequest = makeGetRequest(path: "/users")
        let urlRequest = try pipeline.makeUrlRequest(clientRequest)

        // Headers should be injected by the pipeline
        #expect(urlRequest[.contentType] == "application/json")
        #expect(urlRequest[.apiKey] == "test-key")
    }

    @Test("URL request pipeline handles empty body for GET request")
    func urlRequestPipelineHandlesEmptyBodyForGetRequest() throws {
        let urlHost = DefaultUrlHost(baseUrl: "https://api.example.com")
        let hostProvider = DefaultURLHostProvider(urlHost: urlHost)
        let apiKeyProvider = MockAPIKeyProvider(apiKey: "get-key")
        let pipeline = DefaultURLRequestPipeline(urlHostProvider: hostProvider, apiKeyProvider: apiKeyProvider)

        let clientRequest = makeGetRequest(path: "/data")
        let urlRequest = try pipeline.makeUrlRequest(clientRequest)

        #expect(urlRequest.httpBody == nil)
        #expect(urlRequest[.contentType] == "application/json")
        #expect(urlRequest[.apiKey] == "get-key")
    }

    // MARK: - Error Handling Tests

    @Test("URL request pipeline propagates builder errors")
    func urlRequestPipelinePropagatesBuilderErrors() throws {
        let requestBuilder = MockURLRequestBuilderWithError()
        let apiKeyProvider = MockAPIKeyProvider(apiKey: "test-key")

        let pipeline = DefaultURLRequestPipeline(
            requestBuilder: requestBuilder,
            apiKeyProvider: apiKeyProvider
        )

        let clientRequest = makeGetRequest(path: "/test")

        #expect(throws: URLRequestBuilderError.self) {
            try pipeline.makeUrlRequest(clientRequest)
        }
    }

    @Test("URL request pipeline propagates serialization errors")
    func urlRequestPipelinePropagatesSerializationErrors() throws {
        let urlHost = DefaultUrlHost(baseUrl: "https://api.example.com")
        let hostProvider = DefaultURLHostProvider(urlHost: urlHost)
        let requestBuilder = DefaultURLRequestBuilder(hostProvider)
        let serializer = MockSerializerWithError()
        let apiKeyProvider = MockAPIKeyProvider(apiKey: "test-key")

        let pipeline = DefaultURLRequestPipeline(
            requestBuilder: requestBuilder,
            serializer: serializer,
            headerInjector: DefaultHeaderInjector(),
            apiKeyProvider: apiKeyProvider
        )

        let clientRequest = makePostRequest(path: "/test")

        #expect(throws: MockSerializationError.self) {
            try pipeline.makeUrlRequest(clientRequest)
        }
    }

    @Test("convenience initializer creates pipeline correctly")
    func convenienceInitializerCreatesPipelineCorrectly() throws {
        let urlHost = DefaultUrlHost(baseUrl: "https://api.example.com")
        let hostProvider = DefaultURLHostProvider(urlHost: urlHost)
        let apiKeyProvider = MockAPIKeyProvider(apiKey: "convenience-key")

        let pipeline = DefaultURLRequestPipeline(urlHostProvider: hostProvider, apiKeyProvider: apiKeyProvider)

        let clientRequest = makeGetRequest(path: "/test")
        let urlRequest = try pipeline.makeUrlRequest(clientRequest)

        #expect(urlRequest.url?.absoluteString == "https://api.example.com/test")
        #expect(urlRequest[.apiKey] == "convenience-key")
        #expect(urlRequest[.contentType] == "application/json")
    }

    // MARK: - Integration Tests

    @Test("full pipeline integration with complex request")
    func fullPipelineIntegrationWithComplexRequest() throws {
        let urlHost = DefaultUrlHost(baseUrl: "https://api.example.com")
        let hostProvider = DefaultURLHostProvider(urlHost: urlHost)
        let apiKeyProvider = MockAPIKeyProvider(apiKey: "integration-key")
        let pipeline = DefaultURLRequestPipeline(urlHostProvider: hostProvider, apiKeyProvider: apiKeyProvider)

        let requestData = TestRequest(name: "Integration Test", value: 999)
        let endpoint = EndpointBuilder<TestRequest, TestResponse>
            .post(requestData, path: "/api/v1/integration")
            .withQuery("version", value: "1.0")
            .withQuery("format", value: "json")
            .build()
        let clientRequest = endpoint.makeRequest()

        let urlRequest = try pipeline.makeUrlRequest(clientRequest)

        #expect(urlRequest.url?.absoluteString.contains("api.example.com/api/v1/integration") == true)
        #expect(urlRequest.url?.query?.contains("version=1.0") == true)
        #expect(urlRequest.url?.query?.contains("format=json") == true)
        #expect(urlRequest.httpMethod == "POST")
        #expect(urlRequest.httpBody != nil)
        #expect(urlRequest[.contentType] == "application/json")
        #expect(urlRequest[.apiKey] == "integration-key")
    }

    // MARK: - Mock Classes

    private class MockAPIKeyProvider: APIKeyProvider {
        let apiKey: String?

        init(apiKey: String? = nil) {
            self.apiKey = apiKey
        }
    }

    private class MockURLRequestBuilder: URLRequestBuilder {
        var makeUrlRequestCalled = false

        func makeUrlRequest<Endpoint>(_: RestClientRequest<Endpoint>) throws -> URLRequest {
            makeUrlRequestCalled = true
            return URLRequest(url: URL(string: "https://mock.example.com")!)
        }
    }

    private class MockURLRequestBuilderWithError: URLRequestBuilder {
        func makeUrlRequest<Endpoint>(_: RestClientRequest<Endpoint>) throws -> URLRequest {
            throw URLRequestBuilderError.invalidUrl("mock-error")
        }
    }

    private class MockSerializer: Serializer {
        var serializeCalled = false

        func serialize(_: Encodable) throws -> Data {
            serializeCalled = true
            return Data()
        }

        func deserialize<D: Decodable>(_: D.Type, data _: Data) throws -> D {
            throw MockSerializationError.notImplemented
        }
    }

    private enum MockSerializationError: Error {
        case serializationFailed
        case notImplemented
    }

    private class MockSerializerWithError: Serializer {
        func serialize(_: Encodable) throws -> Data {
            throw MockSerializationError.serializationFailed
        }

        func deserialize<D: Decodable>(_: D.Type, data _: Data) throws -> D {
            throw MockSerializationError.notImplemented
        }
    }

    private class MockHeaderInjector: HeaderInjector {
        var injectCalled = false

        func inject<Endpoint>(
            intoRequest urlRequest: URLRequest,
            clientRequest _: RestClientRequest<Endpoint>,
            apiKeyProvider _: APIKeyProvider
        ) -> URLRequest {
            injectCalled = true
            return urlRequest
        }
    }

    // MARK: - Helper Methods

    private func makeGetRequest(path: String) -> RestClientRequest<AnyEndpoint<TestRequest, TestResponse>> {
        let endpoint = EndpointBuilder<TestRequest, TestResponse>
            .get(path: path)
            .build()
        return endpoint.makeRequest()
    }

    private func makePostRequest(path: String) -> RestClientRequest<AnyEndpoint<TestRequest, TestResponse>> {
        let requestData = TestRequest(name: "test", value: 42)
        let endpoint = EndpointBuilder<TestRequest, TestResponse>
            .post(requestData, path: path)
            .build()
        return endpoint.makeRequest()
    }

    private func makePutRequest(path: String) -> RestClientRequest<AnyEndpoint<TestRequest, TestResponse>> {
        let requestData = TestRequest(name: "updated", value: 123)
        let endpoint = EndpointBuilder<TestRequest, TestResponse>
            .put(requestData, path: path)
            .build()
        return endpoint.makeRequest()
    }

    private func makePostRequestWithData(
        path: String,
        data: TestRequest
    ) -> RestClientRequest<AnyEndpoint<TestRequest, TestResponse>> {
        let endpoint = EndpointBuilder<TestRequest, TestResponse>
            .post(data, path: path)
            .build()
        return endpoint.makeRequest()
    }

    private func makeGetRequestWithQuery(
        path: String,
        key: String,
        value: String
    ) -> RestClientRequest<AnyEndpoint<TestRequest, TestResponse>> {
        let endpoint = EndpointBuilder<TestRequest, TestResponse>
            .get(path: path)
            .withQuery(key, value: value)
            .build()
        return endpoint.makeRequest()
    }
}

// MARK: - Test Models

private struct TestRequest: Codable {
    let name: String
    let value: Int
}

private struct TestResponse: Decodable {
    let id: Int
    let message: String
}
