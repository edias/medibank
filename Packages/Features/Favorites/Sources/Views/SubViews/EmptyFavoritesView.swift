//
//  EmptyFavoritesView.swift
//  Favorites
//
//  Created by Eduardo Dias on 01/09/2025.
//

import SwiftUI

import CommonUI

struct EmptyFavoritesView: View {

    var body: some View {

        VStack(spacing: DesignSystem.metrics.extraLarge) {

            Image(systemName: "heart")
                .font(.system(size: DesignSystem.metrics.buttonSize))
                .foregroundColor(DesignSystem.colors.secondaryText)

            Text("No Favorites Yet")
                .font(DesignSystem.typography.title2)
                .fontWeight(DesignSystem.typography.semibold)

            Text("Save articles from Headlines to see them here")
                .font(DesignSystem.typography.body)
                .foregroundColor(DesignSystem.colors.secondaryText)
                .multilineTextAlignment(.center)
        }
        .padding(32)
    }
}
