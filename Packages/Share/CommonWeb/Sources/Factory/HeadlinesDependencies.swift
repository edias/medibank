//
//  HeadlinesFactory.swift
//  Headlines
//
//  Created by Eduardo Dias on 31/08/2025.
//

import SwiftUI
import Storage

public protocol CommonWebDependencies {
    var articlesStorage: ArticlesStorage { get }
}

public protocol FeatureFactory {
    associatedtype RootView: View
    func makeRootView(article: Article) -> RootView
}

public struct CommonWebFactory: @preconcurrency FeatureFactory {

    private let dependencies: CommonWebDependencies

    public init(_ dependencies: CommonWebDependencies) {
        self.dependencies = dependencies
    }

    @MainActor
    public func makeRootView(article: Article) -> some View {
        let observableArticlesStorage = ObservableArticlesStorage(storage: dependencies.articlesStorage)
        return WebPageView(article: article).environmentObject(observableArticlesStorage)
    }
}
