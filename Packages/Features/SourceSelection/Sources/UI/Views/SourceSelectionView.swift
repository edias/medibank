//
//  SourceSelectionView.swift
//  SourceSelection
//
//  Created by Eduardo Dias on 30/08/2025.
//

import SwiftUI

import CommonUI

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
            .padding(.top, DesignSystem.metrics.cardMargin)
            .navigationTitle(viewModel.title)
            .task {
                await viewModel.loadSources()
            }
        }
    }
}
