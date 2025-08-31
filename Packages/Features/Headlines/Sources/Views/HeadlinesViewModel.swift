//
//  HeadlinesViewModel.swift
//  Headlines
//
//  Created by Eduardo Dias on 31/08/2025.
//

import Combine
import Storage

final class HeadlinesViewModel: ObservableObject {

    @Published
    private(set) var headlines: [Article] = []

    private let networkServices: HeadlinesNetworkServices

    private let storage: SelectionStorage

    init(networkServices: HeadlinesNetworkServices, storage: SelectionStorage) {
        self.networkServices = networkServices
        self.storage = storage
    }

    @MainActor
    func loadArticles() async {

        do {
            headlines = try await networkServices.fetchHeadlines(bySources: storage.selections)
        } catch {
            // TODO: Implement failure scenarioa
        }
    }
}
