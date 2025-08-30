//
//  TagStyle.swift
//  SourceSelection
//
//  Created by Eduardo Dias on 30/08/2025.
//

import SwiftUI

struct TagStyle: ViewModifier {

    func body(content: Content) -> some View {

        content
            .font(.caption2)
            .padding(.horizontal, Metrics.medium)
            .padding(.vertical, Metrics.extraSmall)
            .background(Color.gray.opacity(0.1))
            .cornerRadius(Metrics.small)
    }
}

extension View {
    func tagStyle() -> some View {
        modifier(TagStyle())
    }
}
