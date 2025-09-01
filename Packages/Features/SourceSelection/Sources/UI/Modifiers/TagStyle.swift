//
//  TagStyle.swift
//  SourceSelection
//
//  Created by Eduardo Dias on 30/08/2025.
//

import SwiftUI

import CommonUI

struct TagStyle: ViewModifier {

    func body(content: Content) -> some View {
        content
            .font(.caption2)
            .padding(.vertical, DesignSystem.metrics.medium)
            .background(DesignSystem.colors.placeholderBackground)
            .cornerRadius(DesignSystem.metrics.cornerExtraSmall)
    }
}

extension View {
    func tagStyle() -> some View {
        modifier(TagStyle())
    }
}
