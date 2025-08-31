import Foundation
import Testing

@testable import RestClient

@Suite("HeaderInjector Tests")
struct HeaderInjectorTests {

    // MARK: - DefaultHeaderInjector Tests

    @Test("header injection with API key")
    func headerInjectionWithAPIKey() {
        let injector = DefaultHeaderInjector()
        let apiKeyProvider = MockAPIKeyProvider(apiKey: "test-api-key-123")
        let clientRequest = makeTestRequest()
        let originalRequest = URLRequest(url: URL(string: "https://example.com/test")!)

        let modifiedRequest = injector.inject(
            intoRequest: originalRequest,
            clientRequest: clientRequest,
            apiKeyProvider: apiKeyProvider
        )

        #expect(modifiedRequest[.apiKey] == "test-api-key-123")
        #expect(modifiedRequest[.contentType] == "application/json")
    }

    @Test("header injection without API key")
    func headerInjectionWithoutAPIKey() {
        let injector = DefaultHeaderInjector()
        let apiKeyProvider = MockAPIKeyProvider(apiKey: nil)
        let clientRequest = makeTestRequest()
        let originalRequest = URLRequest(url: URL(string: "https://example.com/test")!)

        let modifiedRequest = injector.inject(
            intoRequest: originalRequest,
            clientRequest: clientRequest,
            apiKeyProvider: apiKeyProvider
        )

        #expect(modifiedRequest[.apiKey] == nil)
        #expect(modifiedRequest[.contentType] == "application/json")
    }

    @Test("header injection with empty API key")
    func headerInjectionWithEmptyAPIKey() {
        let injector = DefaultHeaderInjector()
        let apiKeyProvider = MockAPIKeyProvider(apiKey: "")
        let clientRequest = makeTestRequest()
        let originalRequest = URLRequest(url: URL(string: "https://example.com/test")!)

        let modifiedRequest = injector.inject(
            intoRequest: originalRequest,
            clientRequest: clientRequest,
            apiKeyProvider: apiKeyProvider
        )

        #expect(modifiedRequest[.apiKey] == "")
        #expect(modifiedRequest[.contentType] == "application/json")
    }

    @Test("header injection preserves existing headers")
    func headerInjectionPreservesExistingHeaders() {
        let injector = DefaultHeaderInjector()
        let apiKeyProvider = MockAPIKeyProvider(apiKey: "test-key")
        let clientRequest = makeTestRequest()

        var originalRequest = URLRequest(url: URL(string: "https://example.com/test")!)
        originalRequest.setValue("keep-me", forHTTPHeaderField: "Custom-Header")
        originalRequest.setValue("Bearer token123", forHTTPHeaderField: "Authorization")

        let modifiedRequest = injector.inject(
            intoRequest: originalRequest,
            clientRequest: clientRequest,
            apiKeyProvider: apiKeyProvider
        )

        #expect(modifiedRequest.value(forHTTPHeaderField: "Custom-Header") == "keep-me")
        #expect(modifiedRequest.value(forHTTPHeaderField: "Authorization") == "Bearer token123")
        #expect(modifiedRequest[.apiKey] == "test-key")
        #expect(modifiedRequest[.contentType] == "application/json")
    }

    @Test("header injection overrides existing content type")
    func headerInjectionOverridesExistingContentType() {
        let injector = DefaultHeaderInjector()
        let apiKeyProvider = MockAPIKeyProvider(apiKey: "test-key")
        let clientRequest = makeTestRequest()

        var originalRequest = URLRequest(url: URL(string: "https://example.com/test")!)
        originalRequest[.contentType] = "text/plain"

        let modifiedRequest = injector.inject(
            intoRequest: originalRequest,
            clientRequest: clientRequest,
            apiKeyProvider: apiKeyProvider
        )

        #expect(modifiedRequest[.contentType] == "application/json")
        #expect(modifiedRequest[.apiKey] == "test-key")
    }

    @Test("header injection overrides existing API key")
    func headerInjectionOverridesExistingAPIKey() {
        let injector = DefaultHeaderInjector()
        let apiKeyProvider = MockAPIKeyProvider(apiKey: "new-api-key")
        let clientRequest = makeTestRequest()

        var originalRequest = URLRequest(url: URL(string: "https://example.com/test")!)
        originalRequest[.apiKey] = "old-api-key"

        let modifiedRequest = injector.inject(
            intoRequest: originalRequest,
            clientRequest: clientRequest,
            apiKeyProvider: apiKeyProvider
        )

        #expect(modifiedRequest[.apiKey] == "new-api-key")
        #expect(modifiedRequest[.contentType] == "application/json")
    }

    @Test("header injection with POST request")
    func headerInjectionWithPostRequest() {
        let injector = DefaultHeaderInjector()
        let apiKeyProvider = MockAPIKeyProvider(apiKey: "post-api-key")
        let clientRequest = makeTestRequestWithPost()

        let originalRequest = URLRequest(url: URL(string: "https://example.com/test")!)

        let modifiedRequest = injector.inject(
            intoRequest: originalRequest,
            clientRequest: clientRequest,
            apiKeyProvider: apiKeyProvider
        )

        #expect(modifiedRequest[.apiKey] == "post-api-key")
        #expect(modifiedRequest[.contentType] == "application/json")
    }

    @Test("header injection does not modify original request")
    func headerInjectionDoesNotModifyOriginalRequest() {
        let injector = DefaultHeaderInjector()
        let apiKeyProvider = MockAPIKeyProvider(apiKey: "test-key")
        let clientRequest = makeTestRequest()

        let originalRequest = URLRequest(url: URL(string: "https://example.com/test")!)

        let modifiedRequest = injector.inject(
            intoRequest: originalRequest,
            clientRequest: clientRequest,
            apiKeyProvider: apiKeyProvider
        )

        #expect(originalRequest[.apiKey] == nil)
        #expect(originalRequest[.contentType] == nil)
        #expect(modifiedRequest[.apiKey] == "test-key")
        #expect(modifiedRequest[.contentType] == "application/json")
    }

    @Test("header injection with special characters in API key")
    func headerInjectionWithSpecialCharactersInAPIKey() {
        let injector = DefaultHeaderInjector()
        let specialAPIKey = "api-key-with-special-chars!@#$%^&*()"
        let apiKeyProvider = MockAPIKeyProvider(apiKey: specialAPIKey)

        let clientRequest = makeTestRequest()
        let originalRequest = URLRequest(url: URL(string: "https://example.com/test")!)

        let modifiedRequest = injector.inject(
            intoRequest: originalRequest,
            clientRequest: clientRequest,
            apiKeyProvider: apiKeyProvider
        )

        #expect(modifiedRequest[.apiKey] == specialAPIKey)
        #expect(modifiedRequest[.contentType] == "application/json")
    }

    @Test("header injection with long API key")
    func headerInjectionWithLongAPIKey() {
        let injector = DefaultHeaderInjector()
        let longAPIKey = String(repeating: "a", count: 1000)
        let apiKeyProvider = MockAPIKeyProvider(apiKey: longAPIKey)

        let clientRequest = makeTestRequest()
        let originalRequest = URLRequest(url: URL(string: "https://example.com/test")!)

        let modifiedRequest = injector.inject(
            intoRequest: originalRequest,
            clientRequest: clientRequest,
            apiKeyProvider: apiKeyProvider
        )

        #expect(modifiedRequest[.apiKey] == longAPIKey)
        #expect(modifiedRequest[.contentType] == "application/json")
    }

    // MARK: - Test Models and Helpers

    private struct MockAPIKeyProvider: APIKeyProvider {

        let apiKey: String?

        init(apiKey: String? = nil) {
            self.apiKey = apiKey
        }
    }

    private func makeTestRequest() -> RestClientRequest<AnyEndpoint<TestRequest, TestResponse>> {
        let endpoint = EndpointBuilder<TestRequest, TestResponse>
            .get(path: "/test")
            .build()

        return endpoint.makeRequest()
    }

    private func makeTestRequestWithPost() -> RestClientRequest<AnyEndpoint<TestRequest, TestResponse>> {
        let requestData = TestRequest(name: "test", value: 42)

        let endpoint = EndpointBuilder<TestRequest, TestResponse>
            .post(requestData, path: "/test")
            .build()

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
