import Foundation
import Testing

@testable import RestClient

@Suite("URLStatusCodeValidator Tests")
struct URLStatusCodeValidatorTests {

    // MARK: - DefaultURLStatusCodeValidator Tests

    @Test("validation passes for 200 status code")
    func validationPassesFor200StatusCode() throws {
        let validator = DefaultURLStatusCodeValidator()
        let responseData = makeResponseData(statusCode: 200)
        let clientRequest = makeGetRequest()

        let result = try validator.validate(responseData, clientRequest: clientRequest)

        #expect(result.data == responseData.data)
        #expect(result.response == responseData.response)
    }

    @Test("validation passes for 201 created status")
    func validationPassesFor201CreatedStatus() throws {
        let validator = DefaultURLStatusCodeValidator()
        let responseData = makeResponseData(statusCode: 201)
        let clientRequest = makePostRequest()

        let result = try validator.validate(responseData, clientRequest: clientRequest)

        #expect(result.data == responseData.data)
        #expect(result.response == responseData.response)
    }

    @Test("validation passes for 204 no content status")
    func validationPassesFor204NoContentStatus() throws {
        let validator = DefaultURLStatusCodeValidator()
        let responseData = makeResponseData(statusCode: 204)
        let clientRequest = makeGetRequest()

        let result = try validator.validate(responseData, clientRequest: clientRequest)

        #expect(result.data == responseData.data)
        #expect(result.response == responseData.response)
    }

    @Test("validation passes for 299 upper bound of 2xx range")
    func validationPassesFor299UpperBoundOf2xxRange() throws {
        let validator = DefaultURLStatusCodeValidator()
        let responseData = makeResponseData(statusCode: 299)
        let clientRequest = makeGetRequest()

        let result = try validator.validate(responseData, clientRequest: clientRequest)

        #expect(result.data == responseData.data)
        #expect(result.response == responseData.response)
    }

    @Test("validation passes for 202 accepted status")
    func validationPassesFor202AcceptedStatus() throws {
        let validator = DefaultURLStatusCodeValidator()
        let responseData = makeResponseData(statusCode: 202)
        let clientRequest = makeGetRequest()

        let result = try validator.validate(responseData, clientRequest: clientRequest)

        #expect(result.data == responseData.data)
        #expect(result.response == responseData.response)
    }

    // MARK: - Error Handling Tests

    @Test("validation throws error for 400 bad request")
    func validationThrowsErrorFor400BadRequest() throws {
        let validator = DefaultURLStatusCodeValidator()
        let responseData = makeResponseData(statusCode: 400)
        let clientRequest = makeGetRequest()

        do {
            _ = try validator.validate(responseData, clientRequest: clientRequest)
            Issue.record("Expected ServerError to be thrown")
        } catch let error as ServerError {
            switch error {
            case let .unknown(data):
                #expect(data == responseData)
            default:
                Issue.record("Expected unknown ServerError")
            }
        }
    }

    @Test("validation throws error for 401 unauthorized")
    func validationThrowsErrorFor401Unauthorized() throws {
        let validator = DefaultURLStatusCodeValidator()
        let responseData = makeResponseData(statusCode: 401)
        let clientRequest = makeGetRequest()

        #expect(throws: ServerError.self) {
            try validator.validate(responseData, clientRequest: clientRequest)
        }
    }

    @Test("validation throws error for 403 forbidden")
    func validationThrowsErrorFor403Forbidden() throws {
        let validator = DefaultURLStatusCodeValidator()
        let responseData = makeResponseData(statusCode: 403)
        let clientRequest = makeGetRequest()

        #expect(throws: ServerError.self) {
            try validator.validate(responseData, clientRequest: clientRequest)
        }
    }

    @Test("validation throws error for 404 not found")
    func validationThrowsErrorFor404NotFound() throws {
        let validator = DefaultURLStatusCodeValidator()
        let responseData = makeResponseData(statusCode: 404)
        let clientRequest = makeGetRequest()

        #expect(throws: ServerError.self) {
            try validator.validate(responseData, clientRequest: clientRequest)
        }
    }

    @Test("validation throws error for 500 internal server error")
    func validationThrowsErrorFor500InternalServerError() throws {
        let validator = DefaultURLStatusCodeValidator()
        let responseData = makeResponseData(statusCode: 500)
        let clientRequest = makeGetRequest()

        #expect(throws: ServerError.self) {
            try validator.validate(responseData, clientRequest: clientRequest)
        }
    }

    @Test("validation throws error for 502 bad gateway")
    func validationThrowsErrorFor502BadGateway() throws {
        let validator = DefaultURLStatusCodeValidator()
        let responseData = makeResponseData(statusCode: 502)
        let clientRequest = makeGetRequest()

        #expect(throws: ServerError.self) {
            try validator.validate(responseData, clientRequest: clientRequest)
        }
    }

    @Test("validation throws error for 503 service unavailable")
    func validationThrowsErrorFor503ServiceUnavailable() throws {
        let validator = DefaultURLStatusCodeValidator()
        let responseData = makeResponseData(statusCode: 503)
        let clientRequest = makeGetRequest()

        #expect(throws: ServerError.self) {
            try validator.validate(responseData, clientRequest: clientRequest)
        }
    }

    @Test("validation throws error for non HTTP response")
    func validationThrowsErrorForNonHttpResponse() throws {
        let validator = DefaultURLStatusCodeValidator()
        let responseData = makeNonHTTPResponseData()
        let clientRequest = makeGetRequest()

        do {
            _ = try validator.validate(responseData, clientRequest: clientRequest)
            Issue.record("Expected ServerError to be thrown")
        } catch let error as ServerError {
            switch error {
            case let .httpURLResponseConversion(data):
                #expect(data == responseData)
            default:
                Issue.record("Expected httpURLResponseConversion ServerError")
            }
        }
    }

    @Test("validation preserves response data for successful requests")
    func validationPreservesResponseDataForSuccessfulRequests() throws {
        let validator = DefaultURLStatusCodeValidator()
        let originalData = "test response data".data(using: .utf8)!
        let responseData = makeResponseDataWithCustomBody(statusCode: 200, data: originalData)
        let clientRequest = makeGetRequest()

        let result = try validator.validate(responseData, clientRequest: clientRequest)

        #expect(result.data == originalData)
        #expect((result.response as? HTTPURLResponse)?.statusCode == 200)
    }

    @Test("validation works with different request types")
    func validationWorksWithDifferentRequestTypes() throws {
        let validator = DefaultURLStatusCodeValidator()
        let responseData = makeResponseData(statusCode: 201)
        let postRequest = makePostRequest()
        let putRequest = makePutRequest()

        let postResult = try validator.validate(responseData, clientRequest: postRequest)
        let putResult = try validator.validate(responseData, clientRequest: putRequest)

        #expect(postResult.data == responseData.data)
        #expect(putResult.data == responseData.data)
    }

    // MARK: - Edge Cases Tests

    @Test("validation throws error for 199 below 2xx range")
    func validationThrowsErrorFor199Below2xxRange() throws {
        let validator = DefaultURLStatusCodeValidator()
        let responseData = makeResponseData(statusCode: 199)
        let clientRequest = makeGetRequest()

        #expect(throws: ServerError.self) {
            try validator.validate(responseData, clientRequest: clientRequest)
        }
    }

    @Test("validation throws error for 300 redirect status")
    func validationThrowsErrorFor300RedirectStatus() throws {
        let validator = DefaultURLStatusCodeValidator()
        let responseData = makeResponseData(statusCode: 300)
        let clientRequest = makeGetRequest()

        #expect(throws: ServerError.self) {
            try validator.validate(responseData, clientRequest: clientRequest)
        }
    }

    @Test("validation throws error for 301 moved permanently")
    func validationThrowsErrorFor301MovedPermanently() throws {
        let validator = DefaultURLStatusCodeValidator()
        let responseData = makeResponseData(statusCode: 301)
        let clientRequest = makeGetRequest()

        #expect(throws: ServerError.self) {
            try validator.validate(responseData, clientRequest: clientRequest)
        }
    }

    @Test("validation handles empty response data")
    func validationHandlesEmptyResponseData() throws {
        let validator = DefaultURLStatusCodeValidator()
        let responseData = makeResponseDataWithCustomBody(statusCode: 200, data: Data())
        let clientRequest = makeGetRequest()

        let result = try validator.validate(responseData, clientRequest: clientRequest)

        #expect(result.data.isEmpty)
        #expect((result.response as? HTTPURLResponse)?.statusCode == 200)
    }

    @Test("validation handles large response data")
    func validationHandlesLargeResponseData() throws {
        let validator = DefaultURLStatusCodeValidator()
        let largeData = Data(count: 1024 * 1024) // 1MB of zeros
        let responseData = makeResponseDataWithCustomBody(statusCode: 200, data: largeData)
        let clientRequest = makeGetRequest()

        let result = try validator.validate(responseData, clientRequest: clientRequest)

        #expect(result.data.count == largeData.count)
        #expect((result.response as? HTTPURLResponse)?.statusCode == 200)
    }

    // MARK: - ServerError Properties Tests

    @Test("server error provides correct status code for 404")
    func serverErrorProvidesCorrectStatusCodeFor404() throws {
        let validator = DefaultURLStatusCodeValidator()
        let responseData = makeResponseData(statusCode: 404)
        let clientRequest = makeGetRequest()

        do {
            _ = try validator.validate(responseData, clientRequest: clientRequest)
            Issue.record("Expected ServerError to be thrown")
        } catch let error as ServerError {
            #expect(error.statusCode == 404)
        }
    }

    @Test("server error provides correct status code for 500")
    func serverErrorProvidesCorrectStatusCodeFor500() throws {
        let validator = DefaultURLStatusCodeValidator()
        let responseData = makeResponseData(statusCode: 500)
        let clientRequest = makeGetRequest()

        do {
            _ = try validator.validate(responseData, clientRequest: clientRequest)
            Issue.record("Expected ServerError to be thrown")
        } catch let error as ServerError {
            #expect(error.statusCode == 500)
        }
    }

    @Test("server error provides failure reason")
    func serverErrorProvidesFailureReason() throws {
        let validator = DefaultURLStatusCodeValidator()
        let responseData = makeNonHTTPResponseData()
        let clientRequest = makeGetRequest()

        do {
            _ = try validator.validate(responseData, clientRequest: clientRequest)
            Issue.record("Expected ServerError to be thrown")
        } catch let error as ServerError {
            #expect(error.failureReason != nil)
            #expect(error.failureReason?.contains("HTTPResponse") == true)
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

    private func makePutRequest() -> RestClientRequest<AnyEndpoint<TestRequest, TestResponse>> {
        let requestData = TestRequest(name: "updated", value: 123)
        let endpoint = EndpointBuilder<TestRequest, TestResponse>
            .put(requestData, path: "/test/1")
            .build()
        return endpoint.makeRequest()
    }

    private func makeResponseData(statusCode: Int) -> URLResponseData {
        let jsonData = "{}".data(using: .utf8)!
        let url = URL(string: "https://api.example.com/test")!
        let httpResponse = HTTPURLResponse(
            url: url,
            statusCode: statusCode,
            httpVersion: "HTTP/1.1",
            headerFields: ["Content-Type": "application/json"]
        )!
        return (data: jsonData, response: httpResponse)
    }

    private func makeResponseDataWithCustomBody(statusCode: Int, data: Data) -> URLResponseData {
        let url = URL(string: "https://api.example.com/test")!
        let httpResponse = HTTPURLResponse(
            url: url,
            statusCode: statusCode,
            httpVersion: "HTTP/1.1",
            headerFields: ["Content-Type": "application/json"]
        )!
        return (data: data, response: httpResponse)
    }

    private func makeNonHTTPResponseData() -> URLResponseData {
        let jsonData = "{}".data(using: .utf8)!
        let url = URL(string: "https://api.example.com/test")!
        let urlResponse = URLResponse(
            url: url,
            mimeType: "application/json",
            expectedContentLength: jsonData.count,
            textEncodingName: nil
        )
        return (data: jsonData, response: urlResponse)
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
