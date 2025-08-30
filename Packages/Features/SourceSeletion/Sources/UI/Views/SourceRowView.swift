//
//  SourceRowView.swift
//  SourceSelection
//
//  Created by Eduardo Dias on 30/08/2025.
//

import SwiftUI

struct SourceRowView: View {

    let source: Source
    let isSelected: Bool
    let onToggle: () -> Void

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

            Button(action: onToggle) {
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(isSelected ? .blue : .gray)
                    .font(.title2)
            }
        }
        .padding(.vertical, Metrics.small)
        .contentShape(Rectangle())
        .onTapGesture {
            onToggle()
        }
    }
}
