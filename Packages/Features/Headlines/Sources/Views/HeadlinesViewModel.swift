//
//  HeadlinesViewModel.swift
//  Headlines
//
//  Created by Eduardo Dias on 31/08/2025.
//

import Combine
import Foundation

import Storage

final class HeadlinesViewModel: ObservableObject {

    @Published
    private(set) var headlines: [Article] = []

    private let networkServices: HeadlinesNetworkServices

    private let storage: SelectionStorage

    private let onTapHeadline: @MainActor (URL) -> Void

    init(networkServices: HeadlinesNetworkServices, storage: SelectionStorage, onTapHeadline: @escaping @MainActor (URL) -> Void) {
        self.networkServices = networkServices
        self.storage = storage
        self.onTapHeadline = onTapHeadline
    }

    @MainActor
    func loadArticles() async {

        do {
            headlines = try await networkServices.fetchHeadlines(bySources: storage.selections)
        } catch {
            headlines = []
            // TODO: Implement failure scenarioa
        }
    }

    @MainActor
    func onTapHeadline(urlString: String) {
        guard let url = URL(string: urlString) else { return }
        onTapHeadline(url)
    }
}
