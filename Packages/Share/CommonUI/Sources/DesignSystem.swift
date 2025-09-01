import SwiftUI
import Foundation

// MARK: - Design System

public enum DesignSystem {
    public static let metrics = Metrics()
    public static let colors = Colors()
    public static let typography = Typography()
}

// MARK: - Spacing & Metrics

public struct Metrics : Sendable{
    
    // Base spacing scale (4pt grid system)
    public let extraSmall: CGFloat = 2    // 2pt
    public let small: CGFloat = 4         // 4pt  
    public let medium: CGFloat = 8        // 8pt
    public let large: CGFloat = 12        // 12pt
    public let extraLarge: CGFloat = 16   // 16pt
    public let huge: CGFloat = 24         // 24pt
    public let massive: CGFloat = 32      // 32pt
    
    // Semantic spacing
    public let cardPadding: CGFloat = 16
    public let cardMargin: CGFloat = 8
    public let badgePadding: CGFloat = 8
    public let iconPadding: CGFloat = 10
    
    // Corner radius
    public let cornerExtraSmall: CGFloat = 4
    public let cornerSmall: CGFloat = 8
    public let cornerMedium: CGFloat = 12
    
    // Standard sizes
    public let thumbnailSmall: CGFloat = 60
    public let thumbnailMedium: CGFloat = 80
    public let buttonSize: CGFloat = 50
    public let iconSize: CGFloat = 40
}

// MARK: - Color Palette

public struct Colors : Sendable{
    // Brand Colors
    public let primary = Color.blue
    public let secondary = Color.purple
    
    // System Colors  
    public let background = Color(.systemBackground)
    public let secondaryBackground = Color(.secondarySystemBackground)
    public let cardBackground = Color(.systemGray6)
    
    // Text Colors
    public let primaryText = Color.primary
    public let secondaryText = Color.secondary
    public let onBrand = Color.white
    
    // UI Element Colors
    public let placeholder = Color.gray
    public let placeholderBackground = Color.gray.opacity(0.1)
    public let success = Color.green
    public let warning = Color.orange
    public let error = Color.red
    
    // Semantic Colors
    public let selected = Color.blue
    public let unselected = Color.gray
    public let overlay = Color.black.opacity(0.3)
}

// MARK: - Typography

public struct Typography : Sendable{
    // Headlines
    public let title1 = Font.largeTitle
    public let title2 = Font.title2
    public let title3 = Font.title3
    public let headline = Font.headline
    
    // Body text
    public let body = Font.body
    public let subheadline = Font.subheadline
    public let caption = Font.caption
    public let caption2 = Font.caption2
    
    // Custom styles
    public let emptyStateIcon = Font.system(size: 50)
    public let buttonText = Font.system(size: 18, weight: .bold)
    
    // Weights
    public let semibold = Font.Weight.semibold
    public let bold = Font.Weight.bold
    
    // Line limits
    public let titleLines = 2
    public let descriptionLines = 3
    public let singleLine = 1
}
