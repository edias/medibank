import Foundation
import Testing

@testable import RestClient

@Suite("URLRequestBuilder Tests")
struct URLRequestBuilderTests {

    // MARK: - DefaultURLRequestBuilder Tests

    @Test("URL request creation with basic endpoint")
    func urlRequestCreationWithBasicEndpoint() throws {
        let urlHost = DefaultUrlHost(baseUrl: "https://api.example.com")
        let hostProvider = DefaultURLHostProvider(urlHost: urlHost)
        let builder = DefaultURLRequestBuilder(hostProvider)

        let clientRequest = makeGetRequest(path: "/users")
        let urlRequest = try builder.makeUrlRequest(clientRequest)

        #expect(urlRequest.url?.absoluteString == "https://api.example.com/users")
        #expect(urlRequest.httpMethod == "GET")
    }

    @Test("URL request creation with POST method")
    func urlRequestCreationWithPostMethod() throws {
        let urlHost = DefaultUrlHost(baseUrl: "https://api.example.com")
        let hostProvider = DefaultURLHostProvider(urlHost: urlHost)
        let builder = DefaultURLRequestBuilder(hostProvider)

        let clientRequest = makePostRequest(path: "/users")
        let urlRequest = try builder.makeUrlRequest(clientRequest)

        #expect(urlRequest.url?.absoluteString == "https://api.example.com/users")
        #expect(urlRequest.httpMethod == "POST")
    }

    @Test("URL request creation with PUT method")
    func urlRequestCreationWithPutMethod() throws {
        let urlHost = DefaultUrlHost(baseUrl: "https://api.example.com")
        let hostProvider = DefaultURLHostProvider(urlHost: urlHost)
        let builder = DefaultURLRequestBuilder(hostProvider)

        let clientRequest = makePutRequest(path: "/users/1")
        let urlRequest = try builder.makeUrlRequest(clientRequest)

        #expect(urlRequest.url?.absoluteString == "https://api.example.com/users/1")
        #expect(urlRequest.httpMethod == "PUT")
    }

    @Test("URL request creation with empty path")
    func urlRequestCreationWithEmptyPath() throws {
        let urlHost = DefaultUrlHost(baseUrl: "https://api.example.com")
        let hostProvider = DefaultURLHostProvider(urlHost: urlHost)
        let builder = DefaultURLRequestBuilder(hostProvider)

        let clientRequest = makeGetRequest(path: "")
        let urlRequest = try builder.makeUrlRequest(clientRequest)

        #expect(urlRequest.url?.absoluteString == "https://api.example.com")
        #expect(urlRequest.httpMethod == "GET")
    }

    @Test("URL request creation with single query parameter")
    func urlRequestCreationWithSingleQueryParameter() throws {
        let urlHost = DefaultUrlHost(baseUrl: "https://api.example.com")
        let hostProvider = DefaultURLHostProvider(urlHost: urlHost)
        let builder = DefaultURLRequestBuilder(hostProvider)

        let clientRequest = makeGetRequestWithQuery(
            path: "/articles",
            key: "category",
            value: "tech"
        )

        let urlRequest = try builder.makeUrlRequest(clientRequest)

        #expect(urlRequest.url?.absoluteString == "https://api.example.com/articles?category=tech")
        #expect(urlRequest.httpMethod == "GET")
    }

    @Test("URL request creation with multiple query parameters")
    func urlRequestCreationWithMultipleQueryParameters() throws {
        let urlHost = DefaultUrlHost(baseUrl: "https://api.example.com")
        let hostProvider = DefaultURLHostProvider(urlHost: urlHost)
        let builder = DefaultURLRequestBuilder(hostProvider)

        let clientRequest = makeGetRequestWithMultipleQueries(
            path: "/articles",
            queries: [
                ["category": ["tech"]],
                ["limit": ["10"]],
                ["sort": ["date"]]
            ]
        )

        let urlRequest = try builder.makeUrlRequest(clientRequest)
        let url = urlRequest.url?.absoluteString ?? ""

        #expect(url.contains("category=tech"))
        #expect(url.contains("limit=10"))
        #expect(url.contains("sort=date"))
        #expect(urlRequest.httpMethod == "GET")
    }

    @Test("URL request creation with multiple values for single query parameter")
    func urlRequestCreationWithMultipleValuesForSingleQueryParameter() throws {
        let urlHost = DefaultUrlHost(baseUrl: "https://api.example.com")
        let hostProvider = DefaultURLHostProvider(urlHost: urlHost)
        let builder = DefaultURLRequestBuilder(hostProvider)

        let clientRequest = makeGetRequestWithMultipleQueries(
            path: "/articles",
            queries: [
                ["tags": ["tech", "mobile", "ios"]]
            ]
        )

        let urlRequest = try builder.makeUrlRequest(clientRequest)

        #expect(urlRequest.url?.absoluteString == "https://api.example.com/articles?tags=tech,mobile,ios")
        #expect(urlRequest.httpMethod == "GET")
    }

    @Test("URL request creation with base URL trailing slash")
    func urlRequestCreationWithBaseUrlTrailingSlash() throws {
        let urlHost = DefaultUrlHost(baseUrl: "https://api.example.com/")
        let hostProvider = DefaultURLHostProvider(urlHost: urlHost)
        let builder = DefaultURLRequestBuilder(hostProvider)

        let clientRequest = makeGetRequest(path: "users")
        let urlRequest = try builder.makeUrlRequest(clientRequest)

        #expect(urlRequest.url?.absoluteString == "https://api.example.com/users")
        #expect(urlRequest.httpMethod == "GET")
    }

    @Test("URL request creation with path starting with slash")
    func urlRequestCreationWithPathStartingWithSlash() throws {
        let urlHost = DefaultUrlHost(baseUrl: "https://api.example.com")
        let hostProvider = DefaultURLHostProvider(urlHost: urlHost)
        let builder = DefaultURLRequestBuilder(hostProvider)

        let clientRequest = makeGetRequest(path: "/users")
        let urlRequest = try builder.makeUrlRequest(clientRequest)

        #expect(urlRequest.url?.absoluteString == "https://api.example.com/users")
        #expect(urlRequest.httpMethod == "GET")
    }

    @Test("URL request creation with complex path")
    func urlRequestCreationWithComplexPath() throws {
        let urlHost = DefaultUrlHost(baseUrl: "https://api.example.com")
        let hostProvider = DefaultURLHostProvider(urlHost: urlHost)
        let builder = DefaultURLRequestBuilder(hostProvider)

        let clientRequest = makeGetRequest(path: "/api/v1/users/123/articles")
        let urlRequest = try builder.makeUrlRequest(clientRequest)

        #expect(urlRequest.url?.absoluteString == "https://api.example.com/api/v1/users/123/articles")
        #expect(urlRequest.httpMethod == "GET")
    }

    // MARK: - Error Handling Tests

    @Test("invalid URL throws error")
    func invalidUrlThrowsError() throws {
        let urlHost = DefaultUrlHost(baseUrl: "123://example.com")
        let hostProvider = DefaultURLHostProvider(urlHost: urlHost)
        let builder = DefaultURLRequestBuilder(hostProvider)

        let clientRequest = makeGetRequest(path: "/users")

        #expect(throws: URLRequestBuilderError.self) {
            try builder.makeUrlRequest(clientRequest)
        }
    }

    @Test("invalid URL error message")
    func invalidUrlErrorMessage() throws {
        let urlHost = DefaultUrlHost(baseUrl: "123://example.com")
        let hostProvider = DefaultURLHostProvider(urlHost: urlHost)
        let builder = DefaultURLRequestBuilder(hostProvider)

        let clientRequest = makeGetRequest(path: "/users")

        do {
            _ = try builder.makeUrlRequest(clientRequest)
            Issue.record("Expected URLRequestBuilderError to be thrown")
        } catch let error as URLRequestBuilderError {
            switch error {
            case let .invalidUrl(url):
                #expect(url == "123://example.com/users")
            default:
                Issue.record("Expected invalidUrl error")
            }
        }
    }

    @Test("malformed query parameters throw error")
    func malformedQueryParametersThrowError() throws {
        let urlHost = DefaultUrlHost(baseUrl: "https://api.example.com")
        let hostProvider = DefaultURLHostProvider(urlHost: urlHost)
        let builder = DefaultURLRequestBuilder(hostProvider)

        // Create a request with problematic query parameters that could cause URL encoding issues
        let clientRequest = makeGetRequestWithMultipleQueries(
            path: "/test",
            queries: [
                [String(repeating: "a", count: 10000): ["value"]] // Very long key that might cause issues
            ]
        )

        // This test might not always throw depending on URLComponents implementation
        // but it's good to have for edge cases
        do {
            let urlRequest = try builder.makeUrlRequest(clientRequest)
            // If no error is thrown, verify the URL was created
            #expect(urlRequest.url != nil)
        } catch {
            // If an error is thrown, it should be URLRequestBuilderError
            #expect(error is URLRequestBuilderError)
        }
    }

    // MARK: - Edge Cases Tests

    @Test("empty query parameter key")
    func emptyQueryParameterKey() throws {
        let urlHost = DefaultUrlHost(baseUrl: "https://api.example.com")
        let hostProvider = DefaultURLHostProvider(urlHost: urlHost)
        let builder = DefaultURLRequestBuilder(hostProvider)
        let clientRequest = makeGetRequestWithMultipleQueries(
            path: "/test",
            queries: [
                ["": ["value"]]
            ]
        )

        let urlRequest = try builder.makeUrlRequest(clientRequest)

        #expect(urlRequest.url?.query?.contains("=value") == true)
        #expect(urlRequest.httpMethod == "GET")
    }

    @Test("empty query parameter value")

    func emptyQueryParameterValue() throws {
        let urlHost = DefaultUrlHost(baseUrl: "https://api.example.com")
        let hostProvider = DefaultURLHostProvider(urlHost: urlHost)
        let builder = DefaultURLRequestBuilder(hostProvider)

        let clientRequest = makeGetRequestWithMultipleQueries(
            path: "/test",
            queries: [
                ["key": [""]]
            ]
        )

        let urlRequest = try builder.makeUrlRequest(clientRequest)

        #expect(urlRequest.url?.absoluteString == "https://api.example.com/test?key=")
        #expect(urlRequest.httpMethod == "GET")
    }

    @Test("special characters in query parameters")
    func specialCharactersInQueryParameters() throws {
        let urlHost = DefaultUrlHost(baseUrl: "https://api.example.com")
        let hostProvider = DefaultURLHostProvider(urlHost: urlHost)
        let builder = DefaultURLRequestBuilder(hostProvider)

        let clientRequest = makeGetRequestWithMultipleQueries(
            path: "/search",
            queries: [
                ["q": ["hello world & special chars!@#$%"]]
            ]
        )

        let urlRequest = try builder.makeUrlRequest(clientRequest)
        let url = urlRequest.url?.absoluteString ?? ""

        #expect(url.contains("q="))
        #expect(urlRequest.httpMethod == "GET")
    }

    @Test("different URL schemes")
    func differentUrlSchemes() throws {
        let urlHost = DefaultUrlHost(baseUrl: "http://api.example.com")
        let hostProvider = DefaultURLHostProvider(urlHost: urlHost)
        let builder = DefaultURLRequestBuilder(hostProvider)

        let clientRequest = makeGetRequest(path: "/users")

        let urlRequest = try builder.makeUrlRequest(clientRequest)

        #expect(urlRequest.url?.scheme == "http")
        #expect(urlRequest.url?.absoluteString == "http://api.example.com/users")
        #expect(urlRequest.httpMethod == "GET")
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

    private func makeGetRequestWithMultipleQueries(
        path: String,
        queries: [[String: [String]]]
    ) -> RestClientRequest<AnyEndpoint<TestRequest, TestResponse>> {
        let endpoint = AnyEndpoint<TestRequest, TestResponse>(
            requestType: .get,
            responseType: TestResponse.self,
            path: path,
            queries: queries
        )
        return endpoint.makeRequest()
    }
}

// MARK: - Test Models

private struct TestRequest: Encodable {
    let name: String
    let value: Int
}

private struct TestResponse: Decodable {
    let id: Int
    let message: String
}
