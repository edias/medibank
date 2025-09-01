//
//  HeadlinesView.swift
//  Headlines
//
//  Created by Eduardo Dias on 31/08/2025.
//

import CommonUI
import SwiftUI

struct HeadlinesView: View {

    @StateObject
    private var viewModel: HeadlinesViewModel

    init(_ viewModel: HeadlinesViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {

        NavigationView {

            VStack {

                switch viewModel.viewState {

                case .loading:
                    ProgressView(viewModel.loadingText)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .foregroundColor(DesignSystem.colors.secondaryText)

                case let .loaded(articles):
                    List(articles, id: \.id) { article in
                        HeadlinesRowView(article: article, onTapHeadline: viewModel.onTapHeadline)
                    }

                case let .error(emptyState), let .noSourcesSelected(emptyState):
                    EmptyStateView(emptyState)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
            .navigationTitle(viewModel.title)
            .task { await viewModel.loadArticles() }
        }
    }
}
