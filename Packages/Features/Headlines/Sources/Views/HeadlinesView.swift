//
//  HeadlinesView.swift
//  Headlines
//
//  Created by Eduardo Dias on 31/08/2025.
//

import SwiftUI
import CommonUI

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
                
                case .loaded(let articles):
                    List(articles, id: \.id) { article in
                        HeadlinesRowView(article: article, onTapHeadline: viewModel.onTapHeadline)
                    }
                
                case .error(let emptyState):
                    EmptyStateView(emptyState: emptyState)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                
                case .noSourcesSelected(let emptyState):
                    EmptyStateView(emptyState: emptyState)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
            .navigationTitle(viewModel.title)
            .task { await viewModel.loadArticles() }
        }
    }
}
