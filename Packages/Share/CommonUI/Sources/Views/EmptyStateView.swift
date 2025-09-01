//
//  EmptyStateView.swift
//  CommonUI
//
//  Created by Eduardo Dias on 01/09/2025.
//

import SwiftUI

public struct EmptyStateView: View {

    let emptyState: EmptyState

    public init(emptyState: EmptyState) {
        self.emptyState = emptyState
    }

    public var body: some View {

        VStack(spacing: DesignSystem.metrics.extraLarge) {

            Image(systemName: emptyState.iconName)
                .font(.system(size: DesignSystem.metrics.buttonSize))
                .foregroundColor(DesignSystem.colors.secondaryText)

            Text(emptyState.title)
                .font(DesignSystem.typography.title2)
                .fontWeight(DesignSystem.typography.semibold)

            Text(emptyState.description)
                .font(DesignSystem.typography.body)
                .foregroundColor(DesignSystem.colors.secondaryText)
                .multilineTextAlignment(.center)
        }
        .padding(DesignSystem.metrics.massive)
    }
}

public struct EmptyState {

    public let iconName: String
    public let title: String
    public let description: String

    public init(iconName: String, title: String, description: String) {
        self.iconName = iconName
        self.title = title
        self.description = description
    }
}

#Preview {
    EmptyStateView(
        emptyState: EmptyState(
            iconName: "tray",
            title: "No Items",
            description: "You don’t have anything here yet."
        )
    )
}
