//
//  HeadlinesViewModel+Factory.swift
//  Headlines
//
//  Created by Eduardo Dias on 01/09/2025.
//

import CommonUI

extension HeadlinesViewModel {

    enum StateFactory {

        static func makeNoSourcesState() -> EmptyState {
            EmptyState(
                iconName: "globe.badge.chevron.down",
                title: "No Sources Selected",
                description: "Please select news sources from the Sources tab to see headlines here."
            )
        }

        static func makeNoArticlesState() -> EmptyState {
            EmptyState(
                iconName: "newspaper",
                title: Constants.noHeadlinesTitle,
                description: Constants.noHeadlinesDescription
            )
        }

        static func makeErrorState() -> EmptyState {
            .init(
                iconName: "exclamationmark.triangle",
                title: "Unable to Load Headlines",
                description: "Please check your internet connection and try again."
            )
        }
    }
}
