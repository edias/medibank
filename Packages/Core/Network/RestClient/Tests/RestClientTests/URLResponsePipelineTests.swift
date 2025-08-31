import Foundation
import Testing

@testable import RestClient

@Suite("URLResponsePipeline Tests")
struct URLResponsePipelineTests {

    // MARK: - DefaultURLResponsePipeline Tests

    @Test("successful response processing with valid status code")
    func successfulResponseProcessingWithValidStatusCode() throws {
        let pipeline = DefaultURLResponsePipeline()
        let responseData = makeSuccessfulResponseData()
        let clientRequest = makeGetRequest()

        let result = try pipeline.makeEndpointResponseData(responseData, clientRequest: clientRequest)

        #expect(result.id == 123)
        #expect(result.message == "Success")
    }

    @Test("response processing with 201 created status")
    func responseProcessingWith201CreatedStatus() throws {
        let pipeline = DefaultURLResponsePipeline()
        let responseData = makeResponseData(statusCode: 201)
        let clientRequest = makeGetRequest()

        let result = try pipeline.makeEndpointResponseData(responseData, clientRequest: clientRequest)

        #expect(result.id == 123)
        #expect(result.message == "Success")
    }

    @Test("response processing with 204 no content status")
    func responseProcessingWith204NoContentStatus() throws {
        let pipeline = DefaultURLResponsePipeline()
        let responseData = makeResponseData(statusCode: 204, responseBody: TestResponse(id: 0, message: ""))
        let clientRequest = makeGetRequest()

        let result = try pipeline.makeEndpointResponseData(responseData, clientRequest: clientRequest)

        #expect(result.id == 0)
        #expect(result.message == "")
    }

    @Test("response processing with different response types")
    func responseProcessingWithDifferentResponseTypes() throws {
        let pipeline = DefaultURLResponsePipeline()
        let customResponse = CustomTestResponse(name: "Test", count: 42, active: true)
        let responseData = makeResponseDataWithCustomType(statusCode: 200, responseBody: customResponse)
        let clientRequest = makeGetRequestWithCustomResponse()

        let result = try pipeline.makeEndpointResponseData(responseData, clientRequest: clientRequest)

        #expect(result.name == "Test")
        #expect(result.count == 42)
        #expect(result.active == true)
    }

    @Test("response processing with custom status code validator")
    func responseProcessingWithCustomStatusCodeValidator() throws {
        let statusValidator = MockURLStatusCodeValidator()
        let serializer = DefaultSerializer()
        let pipeline = DefaultURLResponsePipeline(statusCodeValidator: statusValidator, serializer: serializer)
        let responseData = makeSuccessfulResponseData()
        let clientRequest = makeGetRequest()

        let result = try pipeline.makeEndpointResponseData(responseData, clientRequest: clientRequest)

        #expect(statusValidator.validateCalled == true)
        #expect(result.id == 123)
        #expect(result.message == "Success")
    }

    @Test("response processing with custom serializer")
    func responseProcessingWithCustomSerializer() throws {
        let statusValidator = DefaultURLStatusCodeValidator()
        let serializer = MockSerializer()
        let pipeline = DefaultURLResponsePipeline(statusCodeValidator: statusValidator, serializer: serializer)
        let responseData = makeSuccessfulResponseData()
        let clientRequest = makeGetRequest()

        let result = try pipeline.makeEndpointResponseData(responseData, clientRequest: clientRequest)

        #expect(serializer.deserializeCalled == true)
        #expect(result.id == 999)
        #expect(result.message == "Mock")
    }

    // MARK: - Error Handling Tests

    @Test("response processing throws error for 400 status code")
    func responseProcessingThrowsErrorFor400StatusCode() throws {
        let pipeline = DefaultURLResponsePipeline()
        let responseData = makeResponseData(statusCode: 400)
        let clientRequest = makeGetRequest()

        #expect(throws: ServerError.self) {
            try pipeline.makeEndpointResponseData(responseData, clientRequest: clientRequest)
        }
    }

    @Test("response processing throws error for 404 status code")
    func responseProcessingThrowsErrorFor404StatusCode() throws {
        let pipeline = DefaultURLResponsePipeline()
        let responseData = makeResponseData(statusCode: 404)
        let clientRequest = makeGetRequest()

        #expect(throws: ServerError.self) {
            try pipeline.makeEndpointResponseData(responseData, clientRequest: clientRequest)
        }
    }

    @Test("response processing throws error for 500 status code")
    func responseProcessingThrowsErrorFor500StatusCode() throws {
        let pipeline = DefaultURLResponsePipeline()
        let responseData = makeResponseData(statusCode: 500)
        let clientRequest = makeGetRequest()

        #expect(throws: ServerError.self) {
            try pipeline.makeEndpointResponseData(responseData, clientRequest: clientRequest)
        }
    }

    @Test("response processing throws error for non HTTP response")
    func responseProcessingThrowsErrorForNonHttpResponse() throws {
        let pipeline = DefaultURLResponsePipeline()
        let responseData = makeNonHTTPResponseData()
        let clientRequest = makeGetRequest()

        #expect(throws: ServerError.self) {
            try pipeline.makeEndpointResponseData(responseData, clientRequest: clientRequest)
        }
    }

    @Test("response processing propagates status validator errors")
    func responseProcessingPropagatesStatusValidatorErrors() throws {
        let statusValidator = MockURLStatusCodeValidatorWithError()
        let pipeline = DefaultURLResponsePipeline(statusCodeValidator: statusValidator)
        let responseData = makeSuccessfulResponseData()
        let clientRequest = makeGetRequest()

        #expect(throws: MockValidationError.self) {
            try pipeline.makeEndpointResponseData(responseData, clientRequest: clientRequest)
        }
    }

    @Test("response processing propagates serialization errors")
    func responseProcessingPropagatesSerializationErrors() throws {
        let serializer = MockSerializerWithError()
        let pipeline = DefaultURLResponsePipeline(serializer: serializer)
        let responseData = makeSuccessfulResponseData()
        let clientRequest = makeGetRequest()

        #expect(throws: MockSerializationError.self) {
            try pipeline.makeEndpointResponseData(responseData, clientRequest: clientRequest)
        }
    }

    @Test("response processing handles malformed JSON")
    func responseProcessingHandlesMalformedJson() throws {
        let pipeline = DefaultURLResponsePipeline()
        let responseData = makeMalformedJSONResponseData()
        let clientRequest = makeGetRequest()

        #expect(throws: DecodingError.self) {
            try pipeline.makeEndpointResponseData(responseData, clientRequest: clientRequest)
        }
    }

    @Test("response processing handles empty response body")
    func responseProcessingHandlesEmptyResponseBody() throws {
        let pipeline = DefaultURLResponsePipeline()
        let responseData = makeEmptyResponseData()
        let clientRequest = makeGetRequest()

        #expect(throws: DecodingError.self) {
            try pipeline.makeEndpointResponseData(responseData, clientRequest: clientRequest)
        }
    }

    // MARK: - Integration Tests

    @Test("full pipeline integration with successful response")
    func fullPipelineIntegrationWithSuccessfulResponse() throws {
        let pipeline = DefaultURLResponsePipeline()
        let complexResponse = TestResponse(id: 456, message: "Integration Success")
        let responseData = makeResponseData(statusCode: 200, responseBody: complexResponse)
        let clientRequest = makePostRequest()

        let result = try pipeline.makeEndpointResponseData(responseData, clientRequest: clientRequest)

        #expect(result.id == 456)
        #expect(result.message == "Integration Success")
    }

    @Test("pipeline preserves response data through validation")
    func pipelinePreservesResponseDataThroughValidation() throws {
        let pipeline = DefaultURLResponsePipeline()
        let originalResponse = TestResponse(id: 789, message: "Preserved Data")
        let responseData = makeResponseData(statusCode: 201, responseBody: originalResponse)
        let clientRequest = makeGetRequest()

        let result = try pipeline.makeEndpointResponseData(responseData, clientRequest: clientRequest)

        #expect(result.id == 789)
        #expect(result.message == "Preserved Data")
    }

    // MARK: - Mock Classes

    private class MockURLStatusCodeValidator: URLStatusCodeValidator {
        var validateCalled = false

        func validate(
            _ responseData: URLResponseData,
            clientRequest _: RestClientRequest<some Any>
        ) throws -> URLResponseData {
            validateCalled = true
            return responseData
        }
    }

    private enum MockValidationError: Error {
        case validationFailed
    }

    private class MockURLStatusCodeValidatorWithError: URLStatusCodeValidator {
        func validate(_: URLResponseData, clientRequest _: RestClientRequest<some Any>) throws -> URLResponseData {
            throw MockValidationError.validationFailed
        }
    }

    private class MockSerializer: Serializer {
        var deserializeCalled = false

        func serialize(_: Encodable) throws -> Data {
            return Data()
        }

        func deserialize<D: Decodable>(_ type: D.Type, data _: Data) throws -> D {
            deserializeCalled = true
            // Return mock data based on the expected type
            if type == TestResponse.self {
                return TestResponse(id: 999, message: "Mock") as! D
            }
            throw MockSerializationError.unsupportedType
        }
    }

    private enum MockSerializationError: Error {
        case serializationFailed
        case unsupportedType
    }

    private class MockSerializerWithError: Serializer {
        func serialize(_: Encodable) throws -> Data {
            throw MockSerializationError.serializationFailed
        }

        func deserialize<D: Decodable>(_: D.Type, data _: Data) throws -> D {
            throw MockSerializationError.serializationFailed
        }
    }

    // MARK: - Helper Methods

    private func makeGetRequest() -> RestClientRequest<AnyEndpoint<TestRequest, TestResponse>> {
        let endpoint = EndpointBuilder<TestRequest, TestResponse>
            .get(path: "/test")
            .build()
        return endpoint.makeRequest()
    }

    private func makePostRequest() -> RestClientRequest<AnyEndpoint<TestRequest, TestResponse>> {
        let requestData = TestRequest(name: "test", value: 42)
        let endpoint = EndpointBuilder<TestRequest, TestResponse>
            .post(requestData, path: "/test")
            .build()
        return endpoint.makeRequest()
    }

    private func makeGetRequestWithCustomResponse() -> RestClientRequest<AnyEndpoint<TestRequest, CustomTestResponse>> {
        let endpoint = EndpointBuilder<TestRequest, CustomTestResponse>
            .get(path: "/test")
            .build()
        return endpoint.makeRequest()
    }

    private func makeSuccessfulResponseData() -> URLResponseData {
        return makeResponseData(statusCode: 200)
    }

    private func makeResponseData(
        statusCode: Int,
        responseBody: TestResponse = TestResponse(id: 123, message: "Success")
    ) -> URLResponseData {
        let jsonData = try! JSONEncoder().encode(responseBody)
        let url = URL(string: "https://api.example.com/test")!
        let httpResponse = HTTPURLResponse(
            url: url,
            statusCode: statusCode,
            httpVersion: "HTTP/1.1",
            headerFields: ["Content-Type": "application/json"]
        )!
        return (data: jsonData, response: httpResponse)
    }

    private func makeResponseDataWithCustomType(
        statusCode: Int,
        responseBody: CustomTestResponse
    ) -> URLResponseData {
        let jsonData = try! JSONEncoder().encode(responseBody)
        let url = URL(string: "https://api.example.com/test")!
        let httpResponse = HTTPURLResponse(
            url: url,
            statusCode: statusCode,
            httpVersion: "HTTP/1.1",
            headerFields: ["Content-Type": "application/json"]
        )!
        return (data: jsonData, response: httpResponse)
    }

    private func makeNonHTTPResponseData() -> URLResponseData {
        let jsonData = try! JSONEncoder().encode(TestResponse(id: 123, message: "Success"))
        let url = URL(string: "https://api.example.com/test")!
        let urlResponse = URLResponse(
            url: url,
            mimeType: "application/json",
            expectedContentLength: jsonData.count,
            textEncodingName: nil
        )
        return (data: jsonData, response: urlResponse)
    }

    private func makeMalformedJSONResponseData() -> URLResponseData {
        let malformedData = "{ invalid json }".data(using: .utf8)!
        let url = URL(string: "https://api.example.com/test")!
        let httpResponse = HTTPURLResponse(
            url: url,
            statusCode: 200,
            httpVersion: "HTTP/1.1",
            headerFields: ["Content-Type": "application/json"]
        )!
        return (data: malformedData, response: httpResponse)
    }

    private func makeEmptyResponseData() -> URLResponseData {
        let emptyData = Data()
        let url = URL(string: "https://api.example.com/test")!
        let httpResponse = HTTPURLResponse(
            url: url,
            statusCode: 200,
            httpVersion: "HTTP/1.1",
            headerFields: ["Content-Type": "application/json"]
        )!
        return (data: emptyData, response: httpResponse)
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
