import CommonUI
import Combine
import Foundation
import Storage
import Testing

@testable import Headlines

@Suite("HeadlinesViewModel Tests")
@MainActor
struct HeadlinesViewModelTests {
    
    @Test("Initial state should be loading")
    func initialState() async throws {

        let mockNetworkServices = MockHeadlinesNetworkServices()
        let mockStorage = MockSelectionStorage()
        let viewModel = HeadlinesViewModel(networkServices: mockNetworkServices, storage: mockStorage, onTapHeadline: { _ in })
        
        if case .loading = viewModel.viewState {
            // Test passes
        } else {
            #expect(Bool(false), "Expected initial state to be loading")
        }
        
        #expect(viewModel.headlines.isEmpty)
    }
    
    @Test("loadArticles should fetch headlines from network service")
    func loadArticlesSuccess() async throws {

        let mockNetworkServices = MockHeadlinesNetworkServices()
        let mockStorage = MockSelectionStorage()
        let viewModel = HeadlinesViewModel(networkServices: mockNetworkServices, storage: mockStorage, onTapHeadline: { _ in })
        
        let expectedArticles = createMockArticles()
        mockNetworkServices.mockArticles = expectedArticles
        mockStorage.mockSelections = ["source1", "source2"]
        
        await viewModel.loadArticles()
        
        // Test loaded state with articles
        if case .loaded(let articles) = viewModel.viewState {
            #expect(articles.count == expectedArticles.count)
            #expect(articles[0].title == expectedArticles[0].title)
        } else {
            #expect(Bool(false), "Expected state to be loaded with articles")
        }
        
        #expect(viewModel.headlines.count == expectedArticles.count)
        #expect(viewModel.headlines[0].title == expectedArticles[0].title)
        #expect(mockNetworkServices.fetchHeadlinesCalled)
        #expect(mockNetworkServices.lastFetchedSources == ["source1", "source2"])
    }
    
    @Test("loadArticles should handle network error gracefully")
    func loadArticlesNetworkError() async throws {

        let mockNetworkServices = MockHeadlinesNetworkServices()
        let mockStorage = MockSelectionStorage()
        let viewModel = HeadlinesViewModel(networkServices: mockNetworkServices, storage: mockStorage, onTapHeadline: { _ in })
        
        mockNetworkServices.shouldThrowError = true
        mockStorage.mockSelections = ["source1"] // Ensure sources are selected
        
        await viewModel.loadArticles()
        
        // Test error state
        if case .error(let emptyState) = viewModel.viewState {
            #expect(!emptyState.title.isEmpty)
            #expect(!emptyState.description.isEmpty)
            #expect(!emptyState.iconName.isEmpty)
        } else {
            #expect(Bool(false), "Expected state to be error")
        }
        
        #expect(viewModel.headlines.isEmpty)
        #expect(mockNetworkServices.fetchHeadlinesCalled)
    }
    
    @Test("loadArticles should use storage selections")
    func loadArticlesUsesStorageSelections() async throws {

        let mockNetworkServices = MockHeadlinesNetworkServices()
        let mockStorage = MockSelectionStorage()
        let viewModel = HeadlinesViewModel(networkServices: mockNetworkServices, storage: mockStorage, onTapHeadline: { _ in })
        
        let testSelections = ["bbc", "cnn", "reuters"]
        mockStorage.mockSelections = testSelections
        mockNetworkServices.mockArticles = []
        
        await viewModel.loadArticles()
        
        #expect(mockNetworkServices.lastFetchedSources == testSelections)
        
        // Test error state when no articles returned
        if case .error(let emptyState) = viewModel.viewState {
            #expect(!emptyState.title.isEmpty)
        } else {
            #expect(Bool(false), "Expected state to be error when no articles returned")
        }
    }
    
    @Test("loadArticles should handle no sources selected")
    func loadArticlesNoSourcesSelected() async throws {

        let mockNetworkServices = MockHeadlinesNetworkServices()
        let mockStorage = MockSelectionStorage()
        let viewModel = HeadlinesViewModel(networkServices: mockNetworkServices, storage: mockStorage, onTapHeadline: { _ in })
        
        mockStorage.mockSelections = [] // No sources selected
        
        await viewModel.loadArticles()
        
        // Test no sources selected state
        if case .noSourcesSelected(let emptyState) = viewModel.viewState {
            #expect(emptyState.title.contains("No Sources"))
            #expect(emptyState.description.contains("Sources"))
            #expect(emptyState.iconName.contains("globe"))
        } else {
            #expect(Bool(false), "Expected state to be noSourcesSelected")
        }
        
        #expect(viewModel.headlines.isEmpty)
        #expect(!mockNetworkServices.fetchHeadlinesCalled) // Network should not be called
    }
    
    @Test("loadArticles should show loading state initially")
    func loadArticlesShowsLoading() async throws {

        let mockNetworkServices = MockHeadlinesNetworkServices()
        let mockStorage = MockSelectionStorage()
        let viewModel = HeadlinesViewModel(networkServices: mockNetworkServices, storage: mockStorage, onTapHeadline: { _ in })
        
        mockStorage.mockSelections = ["source1"]
        mockNetworkServices.mockArticles = createMockArticles()
        
        // Start loading (but don't await yet)
        let loadTask = Task {
            await viewModel.loadArticles()
        }
        
        // Check that loading state is set
        if case .loading = viewModel.viewState {
            // Test passes
        } else {
            #expect(Bool(false), "Expected state to be loading during network call")
        }
        
        await loadTask.value
        
        // After loading, should be in loaded state
        if case .loaded = viewModel.viewState {
            // Test passes
        } else {
            #expect(Bool(false), "Expected state to be loaded after successful network call")
        }
    }
    
    @Test("ViewModel should expose title and loading text constants")
    func viewModelConstants() async throws {
        
        let mockNetworkServices = MockHeadlinesNetworkServices()
        let mockStorage = MockSelectionStorage()
        let viewModel = HeadlinesViewModel(networkServices: mockNetworkServices, storage: mockStorage, onTapHeadline: { _ in })
        
        #expect(viewModel.title == "Headlines")
        #expect(viewModel.loadingText == "Loading Headlines...")
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
    
    func toggleSelection(for sourceId: String) {
        if mockSelections.contains(sourceId) {
            mockSelections.removeAll { $0 == sourceId }
        } else {
            mockSelections.append(sourceId)
        }
    }
    
    func isSelected(_ sourceId: String) -> Bool {
        return mockSelections.contains(sourceId)
    }
}

// MARK: - Helper Functions

private func createMockArticles() -> [Article] {

    let source = Storage.ArticleSource(id: "test-source", name: "Test Source")
    
    return [
        Article(
            source: source,
            author: "John Doe",
            title: "Test Article 1",
            description: "This is a test article description",
            url: "https://example.com/article1",
            urlToImage: "https://example.com/image1.jpg",
            publishedAt: "2025-08-31T10:00:00Z"
        ),
        Article(
            source: source,
            author: "Jane Smith",
            title: "Test Article 2",
            description: "This is another test article description",
            url: "https://example.com/article2",
            urlToImage: "https://example.com/image2.jpg",
            publishedAt: "2025-08-31T11:00:00Z"
        )
    ]
}
