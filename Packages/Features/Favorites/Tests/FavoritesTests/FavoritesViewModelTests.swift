import Testing
import Combine
import Foundation
import Storage
import CommonUI
@testable import Favorites

@Suite("FavoritesViewModel Tests")
@MainActor
struct FavoritesViewModelTests {
    
    @Test("Initial state should be loading")
    func initialState() async throws {

        let mockStorage = MockArticlesStorage()
        let viewModel = FavoritesViewModel(articlesStorage: mockStorage, onTapFavorite: { _ in })
        
        if case .loading = viewModel.viewState {
            // Test passes
        } else {
            #expect(Bool(false), "Expected initial state to be loading")
        }
        
        #expect(viewModel.savedArticles.isEmpty)
    }
    
    @Test("loadFavorites should show loading then loaded state with articles")
    func loadFavoritesWithArticles() async throws {

        let mockStorage = MockArticlesStorage()
        let expectedArticles = createMockArticles()
        mockStorage.mockArticles = expectedArticles
        
        let viewModel = FavoritesViewModel(articlesStorage: mockStorage, onTapFavorite: { _ in })
        
        viewModel.loadFavorites()
        
        // Test loaded state with articles
        if case .loaded(let articles) = viewModel.viewState {
            #expect(articles.count == expectedArticles.count)
            #expect(articles[0].title == expectedArticles[0].title)
        } else {
            #expect(Bool(false), "Expected state to be loaded with articles")
        }
        
        #expect(viewModel.savedArticles.count == expectedArticles.count)
    }
    
    @Test("loadFavorites should show empty state when no articles")
    func loadFavoritesEmpty() async throws {

        let mockStorage = MockArticlesStorage()
        mockStorage.mockArticles = [] // No articles
        
        let viewModel = FavoritesViewModel(articlesStorage: mockStorage, onTapFavorite: { _ in })
        
        viewModel.loadFavorites()
        
        // Test empty state
        if case .empty(let emptyState) = viewModel.viewState {
            #expect(emptyState.title == "No Favorites Yet")
            #expect(emptyState.description.contains("Headlines"))
            #expect(emptyState.iconName == "heart")
        } else {
            #expect(Bool(false), "Expected state to be empty")
        }
        
        #expect(viewModel.savedArticles.isEmpty)
    }
    
    @Test("ArticlesStorage publisher updates should trigger state changes")
    func storagePublisherUpdates() async throws {

        let mockStorage = MockArticlesStorage()
        mockStorage.mockArticles = []
        
        let viewModel = FavoritesViewModel(articlesStorage: mockStorage, onTapFavorite: { _ in })
        
        // Initially empty
        viewModel.loadFavorites()
        if case .empty = viewModel.viewState {
            // Expected
        } else {
            #expect(Bool(false), "Expected initial state to be empty")
        }
        
        // Add articles and trigger publisher
        let newArticles = createMockArticles()
        mockStorage.mockArticles = newArticles
        mockStorage.triggerPublisher()
        
        // Give time for async update
        try await Task.sleep(nanoseconds: 100_000_000) // 0.1 second
        
        // Should now be loaded
        if case .loaded(let articles) = viewModel.viewState {
            #expect(articles.count == newArticles.count)
        } else {
            #expect(Bool(false), "Expected state to be loaded after publisher update")
        }
    }
    
    @Test("deleteArticles should remove articles from storage")
    func deleteArticles() async throws {

        let mockStorage = MockArticlesStorage()
        let articles = createMockArticles()
        mockStorage.mockArticles = articles
        
        let viewModel = FavoritesViewModel(articlesStorage: mockStorage, onTapFavorite: { _ in })
        
        viewModel.loadFavorites()
        
        // Ensure we're in loaded state
        guard case .loaded(let loadedArticles) = viewModel.viewState else {
            #expect(Bool(false), "Expected loaded state before deletion")
            return
        }
        
        #expect(loadedArticles.count == 2)
        
        // Delete first article
        let indexSet = IndexSet([0])
        viewModel.deleteArticles(at: indexSet)
        
        // Verify removal was called with correct URL
        #expect(mockStorage.removedArticleURLs.contains(articles[0].url))
        #expect(mockStorage.removedArticleURLs.count == 1)
    }
    
    @Test("deleteArticles should not do anything if not in loaded state")
    func deleteArticlesInEmptyState() async throws {

        let mockStorage = MockArticlesStorage()
        mockStorage.mockArticles = []
        
        let viewModel = FavoritesViewModel(articlesStorage: mockStorage, onTapFavorite: { _ in })
        
        viewModel.loadFavorites()
        
        // Ensure we're in empty state
        guard case .empty = viewModel.viewState else {
            #expect(Bool(false), "Expected empty state")
            return
        }
        
        // Try to delete (should not work)
        let indexSet = IndexSet([0])
        viewModel.deleteArticles(at: indexSet)
        
        // Verify no removal was called
        #expect(mockStorage.removedArticleURLs.isEmpty)
    }
    
    @Test("ViewModel should expose title and loading text constants")
    func viewModelConstants() async throws {

        let mockStorage = MockArticlesStorage()
        let viewModel = FavoritesViewModel(articlesStorage: mockStorage, onTapFavorite: { _ in })
        
        #expect(viewModel.title == "Favorites")
        #expect(viewModel.loadingText == "Loading Favorites...")
    }
    
    @Test("onTapFavorite should be called when provided")
    func onTapFavoriteCallback() async throws {

        let mockStorage = MockArticlesStorage()
        let articles = createMockArticles()
        mockStorage.mockArticles = articles
        
        var tappedArticle: Article?
        let viewModel = FavoritesViewModel(articlesStorage: mockStorage) { article in
            tappedArticle = article
        }
        
        // Test that the callback is stored and can be called
        viewModel.onTapFavorite(articles[0])
        
        #expect(tappedArticle?.title == articles[0].title)
        #expect(tappedArticle?.url == articles[0].url)
    }
}

// MARK: - Mock Classes

final class MockArticlesStorage: ArticlesStorage {

    var mockArticles: [Article] = []
    var removedArticleURLs: [String] = []
    
    private let articlesSubject = CurrentValueSubject<[Article], Never>([])
    
    var articles: [Article] {
        return mockArticles
    }
    
    var articlesPublisher: AnyPublisher<[Article], Never> {
        articlesSubject.eraseToAnyPublisher()
    }
    
    func toggleArticle(for article: Article) {
        if let index = mockArticles.firstIndex(where: { $0.url == article.url }) {
            mockArticles.remove(at: index)
        } else {
            mockArticles.append(article)
        }
        triggerPublisher()
    }
    
    func removeArticle(_ urlString: String) {
        removedArticleURLs.append(urlString)
        mockArticles.removeAll { $0.url == urlString }
        triggerPublisher()
    }
    
    func isArticleSaved(_ urlString: String) -> Bool {
        return mockArticles.contains { $0.url == urlString }
    }
    
    func triggerPublisher() {
        articlesSubject.send(mockArticles)
    }
}

// MARK: - Helper Functions

private func createMockArticles() -> [Article] {
    let source = Storage.ArticleSource(id: "test-source", name: "Test Source")
    
    return [
        Article(
            source: source,
            author: "John Doe",
            title: "Test Favorite Article 1",
            description: "This is a test favorite article description",
            url: "https://example.com/favorite1",
            urlToImage: "https://example.com/image1.jpg",
            publishedAt: "2025-09-01T10:00:00Z"
        ),
        Article(
            source: source,
            author: "Jane Smith", 
            title: "Test Favorite Article 2",
            description: "This is another test favorite article description",
            url: "https://example.com/favorite2",
            urlToImage: "https://example.com/image2.jpg",
            publishedAt: "2025-09-01T11:00:00Z"
        )
    ]
}
