//
//  SourceRowView.swift
//  SourceSelection
//
//  Created by Eduardo Dias on 30/08/2025.
//

import SwiftUI
import Storage

struct SourceRowView: View {

    let source: Source

    @EnvironmentObject
    private var storage: ObservableSelectionStorage

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: Metrics.small) {
                Text(source.name)
                    .font(.headline)

                Text(source.description)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(2)

                HStack {
                    Text(source.category.capitalized)
                        .tagStyle()

                    Text(source.country.uppercased())
                        .tagStyle()
                }
            }

            Spacer()

            Button(action: { storage.toggleSelection(for: source) }) {
                Image(systemName: storage.isSelected(source) ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(storage.isSelected(source) ? .blue : .gray)
                    .font(.title2)
            }
        }
        .padding(.vertical, Metrics.small)
        .contentShape(Rectangle())
        .onTapGesture {
            storage.toggleSelection(for: source)
        }
    }
}
