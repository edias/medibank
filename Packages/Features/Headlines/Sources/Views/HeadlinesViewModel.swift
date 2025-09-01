//
//  HeadlinesViewModel.swift
//  Headlines
//
//  Created by Eduardo Dias on 31/08/2025.
//

import Combine
import Foundation

import Storage
import CommonUI

final class HeadlinesViewModel: ObservableObject {

    var title: String { Constants.title }
    var loadingText: String { Constants.loadingText }

    @Published
    private(set) var viewState: HeadlinesViewState = .loading

    var headlines: [Article] {
        guard case .loaded(let articles) = viewState else { return [] }
        return articles
    }

    private let networkServices: HeadlinesNetworkServices

    private let storage: SelectionStorage

    private let onTapHeadline: @MainActor (Article) -> Void

    init(networkServices: HeadlinesNetworkServices, storage: SelectionStorage, onTapHeadline: @escaping @MainActor (Article) -> Void) {
        self.networkServices = networkServices
        self.storage = storage
        self.onTapHeadline = onTapHeadline
    }

    @MainActor
    func loadArticles() async {

        // Set loading state before network call
        viewState = .loading
        
        // Check if no sources are selected
        guard !storage.selections.isEmpty else {
            viewState = .noSourcesSelected(StateFactory.makeNoSourcesState())
            return
        }

        do {
            let articles = try await networkServices.fetchHeadlines(bySources: storage.selections)
            viewState = articles.isEmpty ? .error(StateFactory.makeNoArticlesState()) : .loaded(articles)
        } catch {
            viewState = .error(StateFactory.makeErrorState())
        }
    }

    @MainActor
    func onTapHeadline(article: Article) {
        onTapHeadline(article)
    }
}
