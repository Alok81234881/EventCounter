import SwiftUI

extension Color {
    // Adaptive background colors
    static var adaptiveBackground: Color {
        Color(uiColor: .systemBackground)
    }
    
    static var adaptiveSecondaryBackground: Color {
        Color(uiColor: .secondarySystemBackground)
    }
    
    static var adaptiveTertiaryBackground: Color {
        Color(uiColor: .tertiarySystemBackground)
    }
    
    // Adaptive text colors
    static var adaptivePrimaryText: Color {
        Color(uiColor: .label)
    }
    
    static var adaptiveSecondaryText: Color {
        Color(uiColor: .secondaryLabel)
    }
    
    static var adaptiveTertiaryText: Color {
        Color(uiColor: .tertiaryLabel)
    }
    
    // Adaptive card/grouped background
    static var adaptiveGroupedBackground: Color {
        Color(uiColor: .systemGroupedBackground)
    }
    
    // Helper for custom adaptive colors
    static func adaptive(light: Color, dark: Color) -> Color {
        Color(UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark ? UIColor(dark) : UIColor(light)
        })
    }
}


extension Color {

    // MARK: - Adaptive Gradient Backgrounds

    /// Primary subtle background gradient
    static var adaptiveGradientBackground: LinearGradient {
        LinearGradient(
            colors: adaptiveGradientColors(
                light: [
                    Color(hex: "#B57EDC")?.opacity(0.15) ?? .purple.opacity(0.15),
                    Color(hex: "#E6D9F2")?.opacity(0.25) ?? .purple.opacity(0.08),
                    .white
                ],
                dark: [
                    Color(hex: "#B57EDC")?.opacity(0.25) ?? .purple.opacity(0.25),
                    Color.black.opacity(0.6),
                    .black
                ]
            ),
            startPoint: .top,
            endPoint: .bottom
        )
    }

    /// Softer version for cards / grouped sections
    static var adaptiveGradientCardBackground: LinearGradient {
        LinearGradient(
            colors: adaptiveGradientColors(
                light: [
                    Color(hex: "#B57EDC")?.opacity(0.08) ?? .purple.opacity(0.08),
                    .white
                ],
                dark: [
                    Color(hex: "#B57EDC")?.opacity(0.18) ?? .purple.opacity(0.18),
                    Color.black.opacity(0.8)
                ]
            ),
            startPoint: .top,
            endPoint: .bottom
        )
    }

    // MARK: - Internal Helper

    private static func adaptiveGradientColors(
        light: [Color],
        dark: [Color]
    ) -> [Color] {
        UITraitCollection.current.userInterfaceStyle == .dark ? dark : light
    }
}
