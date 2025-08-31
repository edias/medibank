//
//  HeadlinesView.swift
//  Headlines
//
//  Created by Eduardo Dias on 31/08/2025.
//

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
                List(viewModel.headlines, id: \.id) { article in
                    HeadlinesRowView(article: article, onTapHeadline: viewModel.onTapHeadline)
                }
            }
            .navigationTitle("Headlines")
            .task { await viewModel.loadArticles() }
        }
    }
}
