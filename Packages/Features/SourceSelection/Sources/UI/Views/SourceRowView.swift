//
//  SourceRowView.swift
//  SourceSelection
//
//  Created by Eduardo Dias on 30/08/2025.
//

import SwiftUI

import CommonUI
import Storage

struct SourceRowView: View {

    let source: Source

    @EnvironmentObject
    private var storage: ObservableSelectionStorage

    var body: some View {

        HStack {

            VStack(alignment: .leading, spacing: DesignSystem.metrics.small) {
                Text(source.name)
                    .font(DesignSystem.typography.headline)

                Text(source.description)
                    .font(DesignSystem.typography.caption)
                    .foregroundColor(DesignSystem.colors.secondaryText)
                    .lineLimit(DesignSystem.typography.titleLines)

                HStack {
                    Text(source.category.capitalized)
                        .tagStyle()

                    Text(source.country.uppercased())
                        .tagStyle()
                }
            }

            Spacer()

            Button(action: { storage.toggleSelection(for: source.id) }) {
                Image(systemName: storage.isSelected(source.id) ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(storage.isSelected(source.id) ? .blue : .gray)
                    .font(DesignSystem.typography.title2)
            }
        }
        .padding(.vertical, DesignSystem.metrics.small)
        .contentShape(Rectangle())
        .onTapGesture {
            storage.toggleSelection(for: source.id)
        }
    }
}
