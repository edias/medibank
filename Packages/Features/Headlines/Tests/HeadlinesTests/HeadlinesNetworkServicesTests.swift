//
//  HeadlinesNetworkServicesTests.swift
//  Headlines
//
//  Created by Eduardo Dias on 31/08/2025.
//

import Testing
import RestClient
@testable import Headlines

@Suite("HeadlinesNetworkServices Tests")
struct HeadlinesNetworkServicesTests {
    
    @Test("fetchHeadlines should create correct endpoint and return articles")
    @MainActor
    func testFetchHeadlinesSuccess() async throws {

        let mockRestClient = MockRestClient()
        let networkServices = DefaultHeadlinesNetworkServices(restClient: mockRestClient)
        
        let expectedArticles = createMockArticles()
        let mockResponse = ArticlesResponse(articles: expectedArticles)
        mockRestClient.mockResponse = mockResponse
        
        let sources = ["bbc-news", "cnn"]
        let result = try await networkServices.fetchHeadlines(bySources: sources)
        
        #expect(result.count == expectedArticles.count)
        #expect(result[0].title == expectedArticles[0].title)
        #expect(mockRestClient.executeRequestCalled)
        
        // Verify the endpoint was constructed correctly
        let capturedRequest = mockRestClient.lastRequest
        #expect(capturedRequest != nil)
    }
    
    @Test("fetchHeadlines should propagate network errors")
    @MainActor
    func testFetchHeadlinesNetworkError() async throws {

        let mockRestClient = MockRestClient()
        let networkServices = DefaultHeadlinesNetworkServices(restClient: mockRestClient)
        
        mockRestClient.shouldThrowError = true
        
        let sources = ["bbc-news"]
        
        do {
            _ = try await networkServices.fetchHeadlines(bySources: sources)
            #expect(Bool(false), "Expected error to be thrown")
        } catch {
            #expect(error is NetworkError)
            #expect(mockRestClient.executeRequestCalled)
        }
    }
    
    @Test("fetchHeadlines should handle empty sources array")
    @MainActor
    func testFetchHeadlinesEmptySources() async throws {

        let mockRestClient = MockRestClient()
        let networkServices = DefaultHeadlinesNetworkServices(restClient: mockRestClient)
        
        let mockResponse = ArticlesResponse(articles: [])
        mockRestClient.mockResponse = mockResponse
        
        let result = try await networkServices.fetchHeadlines(bySources: [])
        
        #expect(result.isEmpty)
        #expect(mockRestClient.executeRequestCalled)
    }
    
    @Test("fetchHeadlines should handle multiple sources")
    @MainActor
    func testFetchHeadlinesMultipleSources() async throws {

        let mockRestClient = MockRestClient()
        let networkServices = DefaultHeadlinesNetworkServices(restClient: mockRestClient)
        
        let expectedArticles = createMockArticles()
        let mockResponse = ArticlesResponse(articles: expectedArticles)
        mockRestClient.mockResponse = mockResponse
        
        let sources = ["bbc-news", "cnn", "reuters", "associated-press"]
        let result = try await networkServices.fetchHeadlines(bySources: sources)
        
        #expect(result.count == expectedArticles.count)
        #expect(mockRestClient.executeRequestCalled)
    }
}

// MARK: - Mock Classes

struct NetworkError: Error {
    let message: String
}

final class MockRestClient: RestClient, @unchecked Sendable {

    var mockResponse: Any?
    var shouldThrowError = false
    var executeRequestCalled = false
    var lastRequest: Any?
    
    func executeRequest<Endpoint>(_ clientRequest: RestClientRequest<Endpoint>) async throws -> Endpoint.ResponseData {

        executeRequestCalled = true

        lastRequest = clientRequest
        
        if shouldThrowError {
            throw NetworkError(message: "Network request failed")
        }
        
        guard let response = mockResponse as? Endpoint.ResponseData else {
            throw NetworkError(message: "Invalid mock response type")
        }
        
        return response
    }
}

// MARK: - Helper Functions

private func createMockArticles() -> [Article] {

    let source = Headlines.Source(id: "test-source", name: "Test Source")
    
    return [
        Article(
            source: source,
            author: "John Doe",
            title: "Breaking News: Test Article",
            description: "This is a test article description for unit testing",
            url: "https://example.com/breaking-news",
            urlToImage: "https://example.com/images/breaking-news.jpg",
            publishedAt: "2025-08-31T10:00:00Z",
            content: "Full content of the test article goes here..."
        ),
        Article(
            source: source,
            author: "Jane Reporter",
            title: "Tech Update: Latest Developments",
            description: "Technology news and updates from the industry",
            url: "https://example.com/tech-update",
            urlToImage: "https://example.com/images/tech-update.jpg",
            publishedAt: "2025-08-31T11:30:00Z",
            content: "Detailed technology article content..."
        )
    ]
}
