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

