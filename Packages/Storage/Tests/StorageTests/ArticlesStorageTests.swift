//
//  ArticlesStorageTests.swift
//  Storage
//
//  Created by Eduardo Dias on 31/08/2025.
//

import Testing
import Combine
import Foundation

@testable import Storage

@Suite("ArticlesStorage Tests")
struct ArticlesStorageTests {
    
    @Test("DefaultArticlesStorage initializes with empty articles")
    func initialState() throws {

        let testDefaults = UserDefaults(suiteName: "ArticlesStorageTests.testInitialState")!
        testDefaults.removePersistentDomain(forName: "ArticlesStorageTests.testInitialState")
        
        let storage = DefaultArticlesStorage(defaults: testDefaults)
        
        #expect(storage.articles.isEmpty)
    }
    
    @Test("DefaultArticlesStorage loads saved articles on initialization")
    func loadSavedArticles() throws {

        let testDefaults = UserDefaults(suiteName: "ArticlesStorageTests.testLoadSavedArticles")!
        testDefaults.removePersistentDomain(forName: "ArticlesStorageTests.testLoadSavedArticles")
        
        let mockArticles = [
            createMockArticle(url: "https://example.com/1"),
            createMockArticle(url: "https://example.com/2")
        ]
        
        // Manually save articles to UserDefaults to simulate existing data
        if let data = try? JSONEncoder().encode(mockArticles) {
            testDefaults.set(data, forKey: "articles")
        }
        
        let storage = DefaultArticlesStorage(defaults: testDefaults)
        
        #expect(storage.articles.count == 2)
        #expect(storage.articles.contains { $0.url == "https://example.com/1" })
        #expect(storage.articles.contains { $0.url == "https://example.com/2" })
    }
    
    @Test("toggleArticle adds new article")
    func toggleArticleAdds() throws {

        let testDefaults = UserDefaults(suiteName: "ArticlesStorageTests.testToggleArticleAdds")!
        testDefaults.removePersistentDomain(forName: "ArticlesStorageTests.testToggleArticleAdds")
        
        let storage = DefaultArticlesStorage(defaults: testDefaults)
        let article = createMockArticle()
        
        storage.toggleArticle(for: article)
        
        #expect(storage.articles.count == 1)
        #expect(storage.articles.contains { $0.url == article.url })
        #expect(storage.isArticleSaved(article.url) == true)
    }
    
    @Test("toggleArticle removes existing article")
    func toggleArticleRemoves() throws {

        let testDefaults = UserDefaults(suiteName: "ArticlesStorageTests.testToggleArticleRemoves")!
        testDefaults.removePersistentDomain(forName: "ArticlesStorageTests.testToggleArticleRemoves")
        
        let storage = DefaultArticlesStorage(defaults: testDefaults)
        let article = createMockArticle()
        
        // Add article first
        storage.toggleArticle(for: article)
        #expect(storage.isArticleSaved(article.url) == true)
        
        // Remove it
        storage.toggleArticle(for: article)
        #expect(storage.articles.isEmpty)
        #expect(storage.isArticleSaved(article.url) == false)
    }
    
    @Test("isArticleSaved returns correct state")
    func isArticleSaved() throws {

        let testDefaults = UserDefaults(suiteName: "ArticlesStorageTests.testIsArticleSaved")!
        testDefaults.removePersistentDomain(forName: "ArticlesStorageTests.testIsArticleSaved")
        
        let storage = DefaultArticlesStorage(defaults: testDefaults)
        let article = createMockArticle()
        
        #expect(storage.isArticleSaved(article.url) == false)
        
        storage.toggleArticle(for: article)
        #expect(storage.isArticleSaved(article.url) == true)
        
        storage.toggleArticle(for: article)
        #expect(storage.isArticleSaved(article.url) == false)
    }
    
    @Test("multiple articles can be managed")
    func multipleArticles() throws {

        let testDefaults = UserDefaults(suiteName: "ArticlesStorageTests.testMultipleArticles")!
        testDefaults.removePersistentDomain(forName: "ArticlesStorageTests.testMultipleArticles")
        
        let storage = DefaultArticlesStorage(defaults: testDefaults)
        let articles = [
            createMockArticle(url: "https://example.com/1"),
            createMockArticle(url: "https://example.com/2"),
            createMockArticle(url: "https://example.com/3")
        ]
        
        // Add all articles
        for article in articles {
            storage.toggleArticle(for: article)
        }
        
        #expect(storage.articles.count == 3)
        for article in articles {
            #expect(storage.isArticleSaved(article.url) == true)
        }
        
        // Remove middle one
        storage.toggleArticle(for: articles[1])
        #expect(storage.articles.count == 2)
        #expect(storage.isArticleSaved(articles[0].url) == true)
        #expect(storage.isArticleSaved(articles[1].url) == false)
        #expect(storage.isArticleSaved(articles[2].url) == true)
    }
    
    @Test("articles persist to UserDefaults")
    func persistenceToUserDefaults() throws {

        let testDefaults = UserDefaults(suiteName: "ArticlesStorageTests.testPersistenceToUserDefaults")!
        testDefaults.removePersistentDomain(forName: "ArticlesStorageTests.testPersistenceToUserDefaults")
        
        let storage = DefaultArticlesStorage(defaults: testDefaults)
        let article = createMockArticle()
        
        storage.toggleArticle(for: article)
        
        let savedData = testDefaults.data(forKey: "articles")
        #expect(savedData != nil)
        
        if let data = savedData,
           let decodedArticles = try? JSONDecoder().decode([Article].self, from: data) {
            #expect(decodedArticles.count == 1)
            #expect(decodedArticles[0].url == article.url)
        }
    }
    
    @Test("articlesPublisher emits changes")
    func articlesPublisher() async throws {

        let testDefaults = UserDefaults(suiteName: "ArticlesStorageTests.testArticlesPublisher")!
        testDefaults.removePersistentDomain(forName: "ArticlesStorageTests.testArticlesPublisher")
        
        let storage = DefaultArticlesStorage(defaults: testDefaults)
        let article = createMockArticle()
        
        // Collect publisher values using AsyncSequence
        let publisherValues = storage.articlesPublisher.values
        var iterator = publisherValues.makeAsyncIterator()
        
        // Get initial value
        let initialValue = await iterator.next()
        #expect(initialValue?.isEmpty == true)
        
        // Add article
        storage.toggleArticle(for: article)
        let afterAdd = await iterator.next()
        #expect(afterAdd?.count == 1)
        #expect(afterAdd?[0].url == article.url)
        
        // Remove article
        storage.toggleArticle(for: article)
        let afterRemove = await iterator.next()
        #expect(afterRemove?.isEmpty == true)
    }
    
    @Test("duplicate articles are not added")
    func duplicateArticles() throws {

        let testDefaults = UserDefaults(suiteName: "ArticlesStorageTests.testDuplicateArticles")!
        testDefaults.removePersistentDomain(forName: "ArticlesStorageTests.testDuplicateArticles")
        
        let storage = DefaultArticlesStorage(defaults: testDefaults)
        let article = createMockArticle()
        
        // Add article twice
        storage.toggleArticle(for: article)
        storage.toggleArticle(for: article)
        
        // Should be removed, not duplicated
        #expect(storage.articles.isEmpty)
    }
    
    @Test("handles empty UserDefaults")
    func handlesEmptyUserDefaults() throws {

        let testDefaults = UserDefaults(suiteName: "ArticlesStorageTests.testHandlesEmptyUserDefaults")!
        testDefaults.removePersistentDomain(forName: "ArticlesStorageTests.testHandlesEmptyUserDefaults")
        // Don't set any value, so data returns nil
        
        let storage = DefaultArticlesStorage(defaults: testDefaults)
        
        #expect(storage.articles.isEmpty)
    }
    
    @Test("removeArticle removes existing article")
    func removeArticle() throws {

        let testDefaults = UserDefaults(suiteName: "ArticlesStorageTests.testRemoveArticle")!
        testDefaults.removePersistentDomain(forName: "ArticlesStorageTests.testRemoveArticle")
        
        let storage = DefaultArticlesStorage(defaults: testDefaults)
        let article = createMockArticle()
        
        // Add article first
        storage.toggleArticle(for: article)
        #expect(storage.isArticleSaved(article.url) == true)
        #expect(storage.articles.count == 1)
        
        // Remove it using removeArticle
        storage.removeArticle(article.url)
        #expect(storage.isArticleSaved(article.url) == false)
        #expect(storage.articles.isEmpty)
    }
    
    @Test("removeArticle handles non-existing article gracefully")
    func removeNonExistingArticle() throws {

        let testDefaults = UserDefaults(suiteName: "ArticlesStorageTests.testRemoveNonExistingArticle")!
        testDefaults.removePersistentDomain(forName: "ArticlesStorageTests.testRemoveNonExistingArticle")
        
        let storage = DefaultArticlesStorage(defaults: testDefaults)
        let urlString = "https://example.com/nonexistent"
        
        // Try to remove an article that doesn't exist
        storage.removeArticle(urlString)
        
        // Should still be empty and not crash
        #expect(storage.articles.isEmpty)
        #expect(storage.isArticleSaved(urlString) == false)
    }
    
    @Test("removeArticle removes only specified article from multiple")
    func removeSpecificArticleFromMultiple() throws {

        let testDefaults = UserDefaults(suiteName: "ArticlesStorageTests.testRemoveSpecificArticleFromMultiple")!
        testDefaults.removePersistentDomain(forName: "ArticlesStorageTests.testRemoveSpecificArticleFromMultiple")
        
        let storage = DefaultArticlesStorage(defaults: testDefaults)
        let articles = [
            createMockArticle(url: "https://example.com/1"),
            createMockArticle(url: "https://example.com/2"),
            createMockArticle(url: "https://example.com/3")
        ]
        
        // Add all articles
        for article in articles {
            storage.toggleArticle(for: article)
        }
        #expect(storage.articles.count == 3)
        
        // Remove middle one using removeArticle
        storage.removeArticle(articles[1].url)
        
        #expect(storage.articles.count == 2)
        #expect(storage.isArticleSaved(articles[0].url) == true)
        #expect(storage.isArticleSaved(articles[1].url) == false)
        #expect(storage.isArticleSaved(articles[2].url) == true)
    }
    
    @Test("removeArticle persists changes to UserDefaults")
    func removeArticlePersistence() throws {

        let testDefaults = UserDefaults(suiteName: "ArticlesStorageTests.testRemoveArticlePersistence")!
        testDefaults.removePersistentDomain(forName: "ArticlesStorageTests.testRemoveArticlePersistence")
        
        let storage = DefaultArticlesStorage(defaults: testDefaults)
        let article = createMockArticle()
        
        // Add and then remove article
        storage.toggleArticle(for: article)
        storage.removeArticle(article.url)
        
        // Check UserDefaults directly
        let savedData = testDefaults.data(forKey: "articles")
        if let data = savedData,
           let decodedArticles = try? JSONDecoder().decode([Article].self, from: data) {
            #expect(decodedArticles.isEmpty)
        }
    }
    
    @Test("removeArticle triggers publisher update")
    func removeArticlePublisher() async throws {
        
        let testDefaults = UserDefaults(suiteName: "ArticlesStorageTests.testRemoveArticlePublisher")!
        testDefaults.removePersistentDomain(forName: "ArticlesStorageTests.testRemoveArticlePublisher")
        
        let storage = DefaultArticlesStorage(defaults: testDefaults)
        let article = createMockArticle()
        
        // Add article first
        storage.toggleArticle(for: article)
        
        // Collect publisher values using AsyncSequence
        let publisherValues = storage.articlesPublisher.values
        var iterator = publisherValues.makeAsyncIterator()
        
        // Get current value (should contain the article)
        let beforeRemove = await iterator.next()
        #expect(beforeRemove?.count == 1)
        #expect(beforeRemove?[0].url == article.url)
        
        // Remove article
        storage.removeArticle(article.url)
        let afterRemove = await iterator.next()
        #expect(afterRemove?.isEmpty == true)
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
