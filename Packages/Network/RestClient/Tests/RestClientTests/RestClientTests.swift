import Foundation
import Testing

@testable import RestClient

@Suite("RestClient Tests")
struct RestClientTests {

    // MARK: - DefaultRestClient Tests

    @Test("successful GET request execution")
    func successfulGetRequestExecution() async throws {

        let mockSession = MockURLSession()
        let urlHost = DefaultUrlHost(baseUrl: "https://api.example.com")
        let hostProvider = DefaultURLHostProvider(urlHost: urlHost)
        let apiKeyProvider = MockAPIKeyProvider(apiKey: "test-key")

        let client = DefaultRestClient(
            session: mockSession,
            urlHostProvider: hostProvider,
            apiKeyProvider: apiKeyProvider
        )

        let expectedResponse = TestResponse(id: 123, message: "Success")
        let responseData = try JSONEncoder().encode(expectedResponse)
        let httpResponse = HTTPURLResponse(
            url: URL(string: "https://api.example.com/users")!,
            statusCode: 200,
            httpVersion: "HTTP/1.1",
            headerFields: nil
        )!

        mockSession.setMockResponse(data: responseData, response: httpResponse)

        let clientRequest = makeGetRequest()
        let result = try await client.executeRequest(clientRequest)

        #expect(result.id == 123)
        #expect(result.message == "Success")
    }

    @Test("successful POST request execution")
    func successfulPostRequestExecution() async throws {

        let mockSession = MockURLSession()
        let urlHost = DefaultUrlHost(baseUrl: "https://api.example.com")
        let hostProvider = DefaultURLHostProvider(urlHost: urlHost)
        let apiKeyProvider = MockAPIKeyProvider(apiKey: "post-key")

        let client = DefaultRestClient(
            session: mockSession,
            urlHostProvider: hostProvider,
            apiKeyProvider: apiKeyProvider
        )

        let expectedResponse = TestResponse(id: 456, message: "Created")
        let responseData = try JSONEncoder().encode(expectedResponse)
        let httpResponse = HTTPURLResponse(
            url: URL(string: "https://api.example.com/users")!,
            statusCode: 201,
            httpVersion: "HTTP/1.1",
            headerFields: nil
        )!

        mockSession.setMockResponse(data: responseData, response: httpResponse)

        let clientRequest = makePostRequest()
        let result = try await client.executeRequest(clientRequest)

        #expect(result.id == 456)
        #expect(result.message == "Created")
    }

    @Test("successful PUT request execution")
    func successfulPutRequestExecution() async throws {

        let mockSession = MockURLSession()
        let urlHost = DefaultUrlHost(baseUrl: "https://api.example.com")
        let hostProvider = DefaultURLHostProvider(urlHost: urlHost)
        let apiKeyProvider = MockAPIKeyProvider(apiKey: "put-key")

        let client = DefaultRestClient(
            session: mockSession,
            urlHostProvider: hostProvider,
            apiKeyProvider: apiKeyProvider
        )

        let expectedResponse = TestResponse(id: 789, message: "Updated")
        let responseData = try JSONEncoder().encode(expectedResponse)
        let httpResponse = HTTPURLResponse(
            url: URL(string: "https://api.example.com/users/1")!,
            statusCode: 200,
            httpVersion: "HTTP/1.1",
            headerFields: nil
        )!

        mockSession.setMockResponse(data: responseData, response: httpResponse)

        let clientRequest = makePutRequest()
        let result = try await client.executeRequest(clientRequest)

        #expect(result.id == 789)
        #expect(result.message == "Updated")
    }

    @Test("convenience initializer creates client correctly")
    func convenienceInitializerCreatesClientCorrectly() throws {

        let urlHost = DefaultUrlHost(baseUrl: "https://api.example.com")
        let hostProvider = DefaultURLHostProvider(urlHost: urlHost)
        let apiKeyProvider = MockAPIKeyProvider(apiKey: "test-key")
        let mockSession = MockURLSession()

        let client = DefaultRestClient(
            session: mockSession,
            urlHostProvider: hostProvider,
            apiKeyProvider: apiKeyProvider
        )

        #expect(client.requestPipeline is DefaultURLRequestPipeline)
        #expect(client.responsePipeline is DefaultURLResponsePipeline)
        #expect(client.session is MockURLSession)
    }

    @Test("client uses default session when not provided")
    func clientUsesDefaultSessionWhenNotProvided() throws {

        let urlHost = DefaultUrlHost(baseUrl: "https://api.example.com")
        let hostProvider = DefaultURLHostProvider(urlHost: urlHost)
        let apiKeyProvider = MockAPIKeyProvider(apiKey: "test-key")

        let client = DefaultRestClient(
            urlHostProvider: hostProvider,
            apiKeyProvider: apiKeyProvider
        )

        #expect(client.session is URLSession)
    }

    @Test("client uses custom pipelines when provided")
    func clientUsesCustomPipelinesWhenProvided() async throws {

        let mockSession = MockURLSession()
        let customRequestPipeline = MockURLRequestPipeline()
        let customResponsePipeline = MockURLResponsePipeline()

        let client = DefaultRestClient(
            session: mockSession,
            requestPipeline: customRequestPipeline,
            responsePipeline: customResponsePipeline
        )

        let expectedResponse = TestResponse(id: 1, message: "Custom")
        let responseData = try JSONEncoder().encode(expectedResponse)
        let httpResponse = HTTPURLResponse(
            url: URL(string: "https://api.example.com/custom")!,
            statusCode: 200,
            httpVersion: "HTTP/1.1",
            headerFields: nil
        )!

        mockSession.setMockResponse(data: responseData, response: httpResponse)

        let clientRequest = makeGetRequest()
        _ = try await client.executeRequest(clientRequest)

        #expect(customRequestPipeline.makeUrlRequestCalled == true)
        #expect(customResponsePipeline.makeEndpointResponseDataCalled == true)
    }

    // MARK: - Error Handling Tests

    @Test("client propagates request pipeline errors")
    func clientPropagatesRequestPipelineErrors() async throws {

        let mockSession = MockURLSession()
        let requestPipeline = MockURLRequestPipelineWithError()
        let responsePipeline = MockURLResponsePipeline()

        let client = DefaultRestClient(
            session: mockSession,
            requestPipeline: requestPipeline,
            responsePipeline: responsePipeline
        )

        let clientRequest = makeGetRequest()

        do {
            _ = try await client.executeRequest(clientRequest)
            Issue.record("Expected MockRequestPipelineError to be thrown")
        } catch {
            #expect(error is MockRequestPipelineError)
        }
    }

    @Test("client propagates response pipeline errors")
    func clientPropagatesResponsePipelineErrors() async throws {

        let mockSession = MockURLSession()
        let requestPipeline = MockURLRequestPipeline()
        let responsePipeline = MockURLResponsePipelineWithError()

        let client = DefaultRestClient(
            session: mockSession,
            requestPipeline: requestPipeline,
            responsePipeline: responsePipeline
        )

        let responseData = Data()
        let httpResponse = HTTPURLResponse(
            url: URL(string: "https://api.example.com/test")!,
            statusCode: 200,
            httpVersion: "HTTP/1.1",
            headerFields: nil
        )!

        mockSession.setMockResponse(data: responseData, response: httpResponse)

        let clientRequest = makeGetRequest()

        do {
            _ = try await client.executeRequest(clientRequest)
            Issue.record("Expected MockResponsePipelineError to be thrown")
        } catch {
            #expect(error is MockResponsePipelineError)
        }
    }

    @Test("client propagates network errors")
    func clientPropagatesNetworkErrors() async throws {

        let mockSession = MockURLSessionWithError()
        let requestPipeline = MockURLRequestPipeline()
        let responsePipeline = MockURLResponsePipeline()

        let client = DefaultRestClient(
            session: mockSession,
            requestPipeline: requestPipeline,
            responsePipeline: responsePipeline
        )

        let clientRequest = makeGetRequest()

        do {
            _ = try await client.executeRequest(clientRequest)
            Issue.record("Expected MockNetworkError to be thrown")
        } catch {
            #expect(error is MockNetworkError)
        }
    }

    @Test("client handles server error responses")
    func clientHandlesServerErrorResponses() async throws {

        let mockSession = MockURLSession()
        let urlHost = DefaultUrlHost(baseUrl: "https://api.example.com")
        let hostProvider = DefaultURLHostProvider(urlHost: urlHost)
        let apiKeyProvider = MockAPIKeyProvider(apiKey: "test-key")

        let client = DefaultRestClient(
            session: mockSession,
            urlHostProvider: hostProvider,
            apiKeyProvider: apiKeyProvider
        )

        let errorData = "Server Error".data(using: .utf8)!
        let httpResponse = HTTPURLResponse(
            url: URL(string: "https://api.example.com/test")!,
            statusCode: 500,
            httpVersion: "HTTP/1.1",
            headerFields: nil
        )!

        mockSession.setMockResponse(data: errorData, response: httpResponse)

        let clientRequest = makeGetRequest()

        do {
            _ = try await client.executeRequest(clientRequest)
            Issue.record("Expected ServerError to be thrown")
        } catch {
            #expect(error is ServerError)
        }
    }

    // MARK: - Integration Tests

    @Test("full integration with real pipelines")
    func fullIntegrationWithRealPipelines() async throws {

        let mockSession = MockURLSession()
        let urlHost = DefaultUrlHost(baseUrl: "https://api.example.com")
        let hostProvider = DefaultURLHostProvider(urlHost: urlHost)
        let apiKeyProvider = MockAPIKeyProvider(apiKey: "integration-key")

        let client = DefaultRestClient(
            session: mockSession,
            urlHostProvider: hostProvider,
            apiKeyProvider: apiKeyProvider
        )

        let expectedResponse = TestResponse(id: 999, message: "Integration Success")
        let responseData = try JSONEncoder().encode(expectedResponse)
        let httpResponse = HTTPURLResponse(
            url: URL(string: "https://api.example.com/integration")!,
            statusCode: 200,
            httpVersion: "HTTP/1.1",
            headerFields: ["Content-Type": "application/json"]
        )!

        mockSession.setMockResponse(data: responseData, response: httpResponse)

        let requestData = TestRequest(name: "Integration", value: 100)
        let endpoint = EndpointBuilder<TestRequest, TestResponse>
            .post(requestData, path: "/integration")
            .withQuery("version", value: "1.0")
            .build()
        let clientRequest = endpoint.makeRequest()

        let result = try await client.executeRequest(clientRequest)

        #expect(result.id == 999)
        #expect(result.message == "Integration Success")
    }

    @Test("client handles different response types")
    func clientHandlesDifferentResponseTypes() async throws {

        let mockSession = MockURLSession()
        let requestPipeline = MockURLRequestPipeline()
        let responsePipeline = MockURLResponsePipeline()

        let client = DefaultRestClient(
            session: mockSession,
            requestPipeline: requestPipeline,
            responsePipeline: responsePipeline
        )

        let customResponse = CustomTestResponse(name: "Custom", count: 42, active: true)
        let responseData = try JSONEncoder().encode(customResponse)
        let httpResponse = HTTPURLResponse(
            url: URL(string: "https://api.example.com/custom")!,
            statusCode: 200,
            httpVersion: "HTTP/1.1",
            headerFields: nil
        )!

        mockSession.setMockResponse(data: responseData, response: httpResponse)

        let clientRequest = makeGetRequestWithCustomResponse()
        let result = try await client.executeRequest(clientRequest)

        #expect(result.name == "Custom")
        #expect(result.count == 42)
        #expect(result.active == true)
    }

    // MARK: - Helper Methods

    private func makeGetRequest() -> RestClientRequest<AnyEndpoint<TestRequest, TestResponse>> {
        let endpoint = EndpointBuilder<TestRequest, TestResponse>
            .get(path: "/users")
            .build()
        return endpoint.makeRequest()
    }

    private func makePostRequest() -> RestClientRequest<AnyEndpoint<TestRequest, TestResponse>> {
        let requestData = TestRequest(name: "test", value: 42)
        let endpoint = EndpointBuilder<TestRequest, TestResponse>
            .post(requestData, path: "/users")
            .build()
        return endpoint.makeRequest()
    }

    private func makePutRequest() -> RestClientRequest<AnyEndpoint<TestRequest, TestResponse>> {
        let requestData = TestRequest(name: "updated", value: 123)
        let endpoint = EndpointBuilder<TestRequest, TestResponse>
            .put(requestData, path: "/users/1")
            .build()
        return endpoint.makeRequest()
    }

    private func makeGetRequestWithCustomResponse() -> RestClientRequest<AnyEndpoint<TestRequest, CustomTestResponse>> {
        let endpoint = EndpointBuilder<TestRequest, CustomTestResponse>
            .get(path: "/custom")
            .build()
        return endpoint.makeRequest()
    }
}

// MARK: - Test Models

private struct TestRequest: Codable {
    let name: String
    let value: Int
}

private struct TestResponse: Codable {
    let id: Int
    let message: String
}

private struct CustomTestResponse: Codable {
    let name: String
    let count: Int
    let active: Bool
}

// MARK: - Mock Classes

private class MockAPIKeyProvider: APIKeyProvider {
    let apiKey: String?

    init(apiKey: String? = nil) {
        self.apiKey = apiKey
    }
}

private class MockURLSession: URLSessionProtocol {
    private var mockData: Data = .init()
    private var mockResponse: URLResponse = .init()
    private var shouldThrow = false
    private var errorToThrow: Error?

    func setMockResponse(data: Data, response: URLResponse) {
        mockData = data
        mockResponse = response
        shouldThrow = false
    }

    func setError(_ error: Error) {
        errorToThrow = error
        shouldThrow = true
    }

    func data(for _: URLRequest) async throws -> (Data, URLResponse) {
        if shouldThrow, let error = errorToThrow {
            throw error
        }
        return (mockData, mockResponse)
    }
}

private class MockURLRequestPipeline: URLRequestPipeline {
    var makeUrlRequestCalled = false

    func makeUrlRequest<Endpoint>(_: RestClientRequest<Endpoint>) throws -> URLRequest {
        makeUrlRequestCalled = true
        return URLRequest(url: URL(string: "https://mock.example.com")!)
    }
}

private enum MockRequestPipelineError: Error {
    case pipelineError
}

private class MockURLRequestPipelineWithError: URLRequestPipeline {
    func makeUrlRequest<Endpoint>(_: RestClientRequest<Endpoint>) throws -> URLRequest {
        throw MockRequestPipelineError.pipelineError
    }
}

private class MockURLResponsePipeline: URLResponsePipeline {
    var makeEndpointResponseDataCalled = false

    func makeEndpointResponseData<Endpoint>(
        _ responseData: URLResponseData,
        clientRequest _: RestClientRequest<Endpoint>
    ) throws -> Endpoint.ResponseData {
        makeEndpointResponseDataCalled = true

        // Return mock data based on the expected type
        if Endpoint.ResponseData.self == TestResponse.self {
            return TestResponse(id: 123, message: "Success") as! Endpoint.ResponseData
        } else if Endpoint.ResponseData.self == CustomTestResponse.self {
            return CustomTestResponse(name: "Custom", count: 42, active: true) as! Endpoint.ResponseData
        }

        // Fallback - attempt to deserialize from response data
        return try JSONDecoder().decode(Endpoint.ResponseData.self, from: responseData.data)
    }
}

private enum MockResponsePipelineError: Error {
    case pipelineError
}

private class MockURLResponsePipelineWithError: URLResponsePipeline {
    func makeEndpointResponseData<Endpoint>(
        _: URLResponseData,
        clientRequest _: RestClientRequest<Endpoint>
    ) throws -> Endpoint.ResponseData {
        throw MockResponsePipelineError.pipelineError
    }
}

private enum MockNetworkError: Error {
    case networkError
}

private class MockURLSessionWithError: URLSessionProtocol {
    func data(for _: URLRequest) async throws -> (Data, URLResponse) {
        throw MockNetworkError.networkError
    }
}
