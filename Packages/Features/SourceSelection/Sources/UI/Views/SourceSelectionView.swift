//
//  SourceSelectionView.swift
//  SourceSelection
//
//  Created by Eduardo Dias on 30/08/2025.
//

import SwiftUI

struct SourceSelectionView: View {

    @StateObject
    private var viewModel: SourceSelectionViewModel

    init(_ viewModel: SourceSelectionViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        NavigationView {
            List(viewModel.sources) { source in
                SourceRowView(source: source)
            }
            .padding(.top, Metrics.medium)
            .navigationTitle("list_title".localized())
            .task {
                await viewModel.loadSources()
            }
        }
    }
}
