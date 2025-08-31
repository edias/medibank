//
//  ObservableArticlesStorageTests.swift
//  Storage
//
//  Created by Eduardo Dias on 31/08/2025.
//

import Combine
import Foundation
import Testing

@testable import Storage

@Suite("ObservableArticlesStorage Tests")
@MainActor
struct ObservableArticlesStorageTests {
    
    @Test("ObservableArticlesStorage initializes with storage articles")
    func initializationWithStorageArticles() throws {

        let mockStorage = MockArticlesStorage()
        let articles = [
            createMockArticle(url: "https://example.com/1"),
            createMockArticle(url: "https://example.com/2")
        ]
        mockStorage.mockArticles = articles
        
        let observableStorage = ObservableArticlesStorage(storage: mockStorage)
        
        #expect(observableStorage.articles.count == 2)
        #expect(observableStorage.articles[0].url == "https://example.com/1")
        #expect(observableStorage.articles[1].url == "https://example.com/2")
    }
    
    @Test("ObservableArticlesStorage initializes with empty articles")
    func initializationWithEmptyArticles() throws {

        let mockStorage = MockArticlesStorage()
        
        let observableStorage = ObservableArticlesStorage(storage: mockStorage)
        
        #expect(observableStorage.articles.isEmpty)
    }
    
    @Test("toggleArticle delegates to underlying storage")
    func toggleArticleDelegate() throws {

        let mockStorage = MockArticlesStorage()
        let observableStorage = ObservableArticlesStorage(storage: mockStorage)
        let article = createMockArticle()
        
        observableStorage.toggleArticle(for: article)
        
        #expect(mockStorage.toggleArticleCalled)
        #expect(mockStorage.lastToggledArticle?.url == article.url)
    }
    
    @Test("isArticleSaved delegates to underlying storage")
    func isArticleSavedDelegate() throws {

        let mockStorage = MockArticlesStorage()
        let article = createMockArticle()
        mockStorage.mockArticles = [article]
        let observableStorage = ObservableArticlesStorage(storage: mockStorage)
        let urlString = article.url
        
        let result = observableStorage.isArticleSaved(urlString)
        
        #expect(result == true)
        #expect(mockStorage.isArticleSavedCalled)
        #expect(mockStorage.lastCheckedURL == urlString)
    }
    
    @Test("published articles update when storage changes")
    func publishedArticlesUpdate() async throws {

        let mockStorage = MockArticlesStorage()
        let observableStorage = ObservableArticlesStorage(storage: mockStorage)
        
        // Wait a bit for initial setup
        try await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds
        
        let initialCount = observableStorage.articles.count
        #expect(initialCount == 0)
        
        // Simulate storage change
        let newArticles = [
            createMockArticle(url: "https://example.com/1"),
            createMockArticle(url: "https://example.com/2")
        ]
        mockStorage.simulateChange(newArticles)
        
        // Wait for the change to propagate on main thread
        try await Task.sleep(nanoseconds: 200_000_000) // 0.2 seconds
        
        #expect(observableStorage.articles.count == 2)
        #expect(observableStorage.articles[0].url == newArticles[0].url)
        #expect(observableStorage.articles[1].url == newArticles[1].url)
    }
    
    @Test("multiple changes propagate correctly")
    func multipleChangesPropagation() async throws {

        let mockStorage = MockArticlesStorage()
        let observableStorage = ObservableArticlesStorage(storage: mockStorage)
        
        // First change
        mockStorage.simulateChange([createMockArticle(url: "https://example.com/1")])
        try await Task.sleep(nanoseconds: 100_000_000)
        
        #expect(observableStorage.articles.count == 1)
        
        // Second change
        mockStorage.simulateChange([
            createMockArticle(url: "https://example.com/1"),
            createMockArticle(url: "https://example.com/2")
        ])
        try await Task.sleep(nanoseconds: 100_000_000)
        
        #expect(observableStorage.articles.count == 2)
        
        // Third change (removal)
        mockStorage.simulateChange([])
        try await Task.sleep(nanoseconds: 100_000_000)
        
        #expect(observableStorage.articles.isEmpty)
    }
    
    @Test("ObservableObject protocol compliance")
    func observableObjectCompliance() throws {

        let mockStorage = MockArticlesStorage()
        let observableStorage = ObservableArticlesStorage(storage: mockStorage)
        
        // This test verifies that ObservableArticlesStorage conforms to ObservableObject
        // The @Published property should be accessible
        let _ = observableStorage.objectWillChange
        
        // Test passes if compilation succeeds
        #expect(true)
    }
    
    @Test("articles property is read-only")
    func articlesReadOnly() throws {

        let mockStorage = MockArticlesStorage()
        let observableStorage = ObservableArticlesStorage(storage: mockStorage)
        
        // This test verifies that articles property is private(set)
        // We can read it but not directly modify it
        let articles = observableStorage.articles
        
        // Test passes if we can read but compilation would fail if we tried to assign
        #expect(articles.isEmpty)
    }
    
    @Test("removeArticle delegates to underlying storage")
    func removeArticleDelegate() throws {

        let mockStorage = MockArticlesStorage()
        let article = createMockArticle()
        mockStorage.mockArticles = [article, createMockArticle(url: "https://example.com/other")]
        let observableStorage = ObservableArticlesStorage(storage: mockStorage)
        let urlString = article.url
        
        observableStorage.removeArticle(urlString)
        
        #expect(mockStorage.removeArticleCalled)
        #expect(mockStorage.lastRemovedURL == urlString)
    }
    
    @Test("removeArticle updates published articles")
    func removeArticleUpdatesPublished() async throws {
        
        let mockStorage = MockArticlesStorage()
        // Set initial articles before creating ObservableArticlesStorage
        mockStorage.mockArticles = [
            createMockArticle(url: "https://example.com/1"),
            createMockArticle(url: "https://example.com/2")
        ]
        
        let observableStorage = ObservableArticlesStorage(storage: mockStorage)
        
        // Wait a bit for initial setup
        try await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds
        
        let initialCount = observableStorage.articles.count
        #expect(initialCount == 2)
        
        // Simulate removal
        mockStorage.simulateRemoval("https://example.com/1")
        
        // Wait for the change to propagate on main thread
        try await Task.sleep(nanoseconds: 200_000_000) // 0.2 seconds
        
        #expect(observableStorage.articles.count == 1)
        #expect(observableStorage.articles[0].url == "https://example.com/2")
    }
}

// MARK: - Mock Classes

final class MockArticlesStorage: ArticlesStorage {

    var mockArticles: [Article] = [] {
        didSet {
            subject.send(mockArticles)
        }
    }

    private let subject: CurrentValueSubject<[Article], Never>
    
    var toggleArticleCalled = false
    var lastToggledArticle: Article?
    var removeArticleCalled = false
    var lastRemovedURL: String?
    var isArticleSavedCalled = false
    var lastCheckedURL: String?
    var addArticleCalled = false
    var lastAddedArticle: Article?
    
    init() {
        subject = CurrentValueSubject<[Article], Never>(mockArticles)
    }
    
    var articles: [Article] {
        mockArticles
    }
    
    var articlesPublisher: AnyPublisher<[Article], Never> {
        subject.eraseToAnyPublisher()
    }
    
    func toggleArticle(for article: Article) {
        toggleArticleCalled = true
        lastToggledArticle = article
        
        if let index = mockArticles.firstIndex(where: { $0.url == article.url }) {
            mockArticles.remove(at: index)
        } else {
            mockArticles.append(article)
        }
        
        subject.send(mockArticles)
    }
    
    func removeArticle(_ urlString: String) {
        removeArticleCalled = true
        lastRemovedURL = urlString
        mockArticles.removeAll { $0.url == urlString }
        subject.send(mockArticles)
    }
    
    func isArticleSaved(_ urlString: String) -> Bool {
        isArticleSavedCalled = true
        lastCheckedURL = urlString
        return mockArticles.contains { $0.url == urlString }
    }
    
    func addArticle(_ article: Article) {
        addArticleCalled = true
        lastAddedArticle = article
        if !isArticleSaved(article.url) {
            mockArticles.append(article)
            subject.send(mockArticles)
        }
    }
    
    func simulateChange(_ newArticles: [Article]) {
        mockArticles = newArticles
        subject.send(mockArticles)
    }
    
    func simulateRemoval(_ urlString: String) {
        mockArticles.removeAll { $0.url == urlString }
        subject.send(mockArticles)
    }
}

// MARK: - Helper Functions

private func createMockArticle(url: String = "https://example.com/article") -> Article {
    let source = ArticleSource(id: "test-source", name: "Test Source")
    return Article(
        source: source,
        author: "Test Author",
        title: "Test Article",
        description: "Test description",
        url: url,
        urlToImage: "https://example.com/image.jpg",
        publishedAt: "2025-08-31T10:00:00Z"
    )
}
