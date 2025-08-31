import Testing
import Combine
import Foundation
import Storage
@testable import Headlines

@Suite("HeadlinesViewModel Tests")
struct HeadlinesViewModelTests {
    
    @Test("Initial state should have empty headlines")
    func testInitialState() async throws {

        let mockNetworkServices = MockHeadlinesNetworkServices()
        let mockStorage = MockSelectionStorage()
        let viewModel = HeadlinesViewModel(networkServices: mockNetworkServices, storage: mockStorage)
        
        #expect(viewModel.headlines.isEmpty)
    }
    
    @Test("loadArticles should fetch headlines from network service")
    @MainActor
    func testLoadArticlesSuccess() async throws {

        let mockNetworkServices = MockHeadlinesNetworkServices()
        let mockStorage = MockSelectionStorage()
        let viewModel = HeadlinesViewModel(networkServices: mockNetworkServices, storage: mockStorage)
        
        let expectedArticles = createMockArticles()
        mockNetworkServices.mockArticles = expectedArticles
        mockStorage.mockSelections = ["source1", "source2"]
        
        await viewModel.loadArticles()
        
        #expect(viewModel.headlines.count == expectedArticles.count)
        #expect(viewModel.headlines[0].title == expectedArticles[0].title)
        #expect(mockNetworkServices.fetchHeadlinesCalled)
        #expect(mockNetworkServices.lastFetchedSources == ["source1", "source2"])
    }
    
    @Test("loadArticles should handle network error gracefully")
    @MainActor
    func testLoadArticlesNetworkError() async throws {

        let mockNetworkServices = MockHeadlinesNetworkServices()
        let mockStorage = MockSelectionStorage()
        let viewModel = HeadlinesViewModel(networkServices: mockNetworkServices, storage: mockStorage)
        
        mockNetworkServices.shouldThrowError = true
        
        await viewModel.loadArticles()
        
        #expect(viewModel.headlines.isEmpty)
        #expect(mockNetworkServices.fetchHeadlinesCalled)
    }
    
    @Test("loadArticles should use storage selections")
    @MainActor
    func testLoadArticlesUsesStorageSelections() async throws {

        let mockNetworkServices = MockHeadlinesNetworkServices()
        let mockStorage = MockSelectionStorage()
        let viewModel = HeadlinesViewModel(networkServices: mockNetworkServices, storage: mockStorage)
        
        let testSelections = ["bbc", "cnn", "reuters"]
        mockStorage.mockSelections = testSelections
        mockNetworkServices.mockArticles = []
        
        await viewModel.loadArticles()
        
        #expect(mockNetworkServices.lastFetchedSources == testSelections)
    }
}

// MARK: - Mock Classes

final class MockHeadlinesNetworkServices: HeadlinesNetworkServices {
    var mockArticles: [Article] = []
    var shouldThrowError = false
    var fetchHeadlinesCalled = false
    var lastFetchedSources: [String] = []
    
    @MainActor
    func fetchHeadlines(bySources sources: [String]) async throws -> [Article] {
        fetchHeadlinesCalled = true
        lastFetchedSources = sources
        
        if shouldThrowError {
            throw NSError(domain: "TestError", code: 1, userInfo: nil)
        }
        
        return mockArticles
    }
}

final class MockSelectionStorage: SelectionStorage {
    var mockSelections: [String] = []
    
    var selections: [String] {
        return mockSelections
    }
    
    var selectionsPublisher: AnyPublisher<[String], Never> {
        Just(mockSelections).eraseToAnyPublisher()
    }
    
    func toggleSelection(for source: Storage.Source) {
        if mockSelections.contains(source.id) {
            mockSelections.removeAll { $0 == source.id }
        } else {
            mockSelections.append(source.id)
        }
    }
    
    func isSelected(_ source: Storage.Source) -> Bool {
        return mockSelections.contains(source.id)
    }
}

// MARK: - Helper Functions

private func createMockArticles() -> [Article] {

    let source = Headlines.Source(id: "test-source", name: "Test Source")
    
    return [
        Article(
            source: source,
            author: "John Doe",
            title: "Test Article 1",
            description: "This is a test article description",
            url: "https://example.com/article1",
            urlToImage: "https://example.com/image1.jpg",
            publishedAt: "2025-08-31T10:00:00Z",
            content: "Test content 1"
        ),
        Article(
            source: source,
            author: "Jane Smith",
            title: "Test Article 2",
            description: "This is another test article description",
            url: "https://example.com/article2",
            urlToImage: "https://example.com/image2.jpg",
            publishedAt: "2025-08-31T11:00:00Z",
            content: "Test content 2"
        )
    ]
}
