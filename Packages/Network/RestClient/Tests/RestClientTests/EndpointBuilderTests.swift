import Testing

@testable import RestClient

@Suite("EndpointBuilder Tests")
struct EndpointBuilderTests {

    // MARK: - GET Endpoint Tests

    @Test("GET endpoint creation without path")
    func getEndpointWithoutPath() {
        let endpoint = EndpointBuilder<TestRequest, TestResponse>.get().build()

        #expect(endpoint.path == "")
        #expect(endpoint.queries.isEmpty)

        switch endpoint.requestType {
        case .get:
            break // Expected
        default:
            Issue.record("Expected GET request type")
        }
    }

    @Test("GET endpoint creation with path")
    func getEndpointWithPath() {
        let endpoint = EndpointBuilder<TestRequest, TestResponse>.get(path: "/users").build()

        #expect(endpoint.path == "/users")
        #expect(endpoint.queries.isEmpty)

        switch endpoint.requestType {
        case .get:
            break // Expected
        default:
            Issue.record("Expected GET request type")
        }
    }

    // MARK: - POST Endpoint Tests

    @Test("POST endpoint creation without path")
    func postEndpointWithoutPath() {
        let requestData = TestRequest(name: "test", value: 42)
        let endpoint = EndpointBuilder<TestRequest, TestResponse>.post(requestData).build()

        #expect(endpoint.path == "")
        #expect(endpoint.queries.isEmpty)

        switch endpoint.requestType {
        case let .post(body):
            #expect(body.name == "test")
            #expect(body.value == 42)
        default:
            Issue.record("Expected POST request type")
        }
    }

    @Test("POST endpoint creation with path")
    func postEndpointWithPath() {
        let requestData = TestRequest(name: "user", value: 123)
        let endpoint = EndpointBuilder<TestRequest, TestResponse>.post(requestData, path: "/api/users").build()

        #expect(endpoint.path == "/api/users")
        #expect(endpoint.queries.isEmpty)

        switch endpoint.requestType {
        case let .post(body):
            #expect(body.name == "user")
            #expect(body.value == 123)
        default:
            Issue.record("Expected POST request type")
        }
    }

    // MARK: - PUT Endpoint Tests

    @Test("PUT endpoint creation without path")
    func putEndpointWithoutPath() {
        let requestData = TestRequest(name: "updated", value: 999)
        let endpoint = EndpointBuilder<TestRequest, TestResponse>.put(requestData).build()

        #expect(endpoint.path == "")
        #expect(endpoint.queries.isEmpty)

        switch endpoint.requestType {
        case let .put(body):
            #expect(body.name == "updated")
            #expect(body.value == 999)
        default:
            Issue.record("Expected PUT request type")
        }
    }

    @Test("PUT endpoint creation with path")
    func putEndpointWithPath() {
        let requestData = TestRequest(name: "modified", value: 456)
        let endpoint = EndpointBuilder<TestRequest, TestResponse>.put(requestData, path: "/api/users/1").build()

        #expect(endpoint.path == "/api/users/1")
        #expect(endpoint.queries.isEmpty)

        switch endpoint.requestType {
        case let .put(body):
            #expect(body.name == "modified")
            #expect(body.value == 456)
        default:
            Issue.record("Expected PUT request type")
        }
    }

    // MARK: - Fluent Configuration Tests

    @Test("withPath fluent configuration")
    func withPath() {
        let endpoint = EndpointBuilder<TestRequest, TestResponse>
            .get()
            .withPath("/custom/path")
            .build()

        #expect(endpoint.path == "/custom/path")
    }

    @Test("withPath override existing path")
    func withPathOverride() {
        let endpoint = EndpointBuilder<TestRequest, TestResponse>
            .get(path: "/original")
            .withPath("/overridden")
            .build()

        #expect(endpoint.path == "/overridden")
    }

    @Test("withQuery single value")
    func withQuerySingleValue() {
        let endpoint = EndpointBuilder<TestRequest, TestResponse>
            .get()
            .withQuery("category", value: "news")
            .build()

        #expect(endpoint.queries.count == 1)
        #expect(endpoint.queries[0]["category"] == ["news"])
    }

    @Test("withQuery multiple values")
    func withQueryMultipleValues() {
        let endpoint = EndpointBuilder<TestRequest, TestResponse>
            .get()
            .withQuery("tags", values: ["tech", "mobile", "ios"])
            .build()

        #expect(endpoint.queries.count == 1)
        #expect(endpoint.queries[0]["tags"] == ["tech", "mobile", "ios"])
    }

    @Test("multiple query parameters")
    func multipleQueryParameters() {
        let endpoint = EndpointBuilder<TestRequest, TestResponse>
            .get()
            .withQuery("category", value: "news")
            .withQuery("limit", value: "10")
            .withQuery("tags", values: ["tech", "mobile"])
            .build()

        #expect(endpoint.queries.count == 3)
        #expect(endpoint.queries[0]["category"] == ["news"])
        #expect(endpoint.queries[1]["limit"] == ["10"])
        #expect(endpoint.queries[2]["tags"] == ["tech", "mobile"])
    }

    // MARK: - Method Chaining Tests

    @Test("full fluent chain for GET")

    func fullFluentChainGet() {
        let endpoint = EndpointBuilder<TestRequest, TestResponse>
            .get()
            .withPath("/api/articles")
            .withQuery("category", value: "tech")
            .withQuery("limit", value: "20")
            .withQuery("sort", values: ["date", "popularity"])
            .build()

        #expect(endpoint.path == "/api/articles")
        #expect(endpoint.queries.count == 3)
        #expect(endpoint.queries[0]["category"] == ["tech"])
        #expect(endpoint.queries[1]["limit"] == ["20"])
        #expect(endpoint.queries[2]["sort"] == ["date", "popularity"])

        switch endpoint.requestType {
        case .get:
            break // Expected
        default:
            Issue.record("Expected GET request type")
        }
    }

    @Test("full fluent chain for POST")
    func fullFluentChainPost() {
        let requestData = TestRequest(name: "article", value: 1)
        let endpoint = EndpointBuilder<TestRequest, TestResponse>
            .post(requestData)
            .withPath("/api/articles")
            .withQuery("publish", value: "true")
            .build()

        #expect(endpoint.path == "/api/articles")
        #expect(endpoint.queries.count == 1)
        #expect(endpoint.queries[0]["publish"] == ["true"])

        switch endpoint.requestType {
        case let .post(body):
            #expect(body.name == "article")
            #expect(body.value == 1)
        default:
            Issue.record("Expected POST request type")
        }
    }

    // MARK: - Response Type Tests

    @Test("response type is correctly set")
    func responseType() {
        let endpoint = EndpointBuilder<TestRequest, TestResponse>
            .get()
            .build()

        #expect(endpoint.responseType == TestResponse.self)
    }

    // MARK: - Empty Values Tests

    @Test("empty path handling")
    func emptyPath() {
        let endpoint = EndpointBuilder<TestRequest, TestResponse>
            .get()
            .withPath("")
            .build()

        #expect(endpoint.path == "")
    }

    @Test("empty query value")
    func emptyQueryValue() {
        let endpoint = EndpointBuilder<TestRequest, TestResponse>
            .get()
            .withQuery("empty", value: "")
            .build()

        #expect(endpoint.queries.count == 1)
        #expect(endpoint.queries[0]["empty"] == [""])
    }

    @Test("empty query values array")
    func emptyQueryValuesArray() {
        let endpoint = EndpointBuilder<TestRequest, TestResponse>
            .get()
            .withQuery("empty", values: [])
            .build()

        #expect(endpoint.queries.count == 1)
        #expect(endpoint.queries[0]["empty"] == [])
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
