import SwiftUI
import Combine

// Theme Enum
enum AppTheme: String, CaseIterable, Identifiable, Codable {
    case system = "System"
    case light = "Light"
    case dark = "Dark"
    
    var id: String { self.rawValue }
}

class ThemeManager: ObservableObject {
    static let shared = ThemeManager()
    
    @AppStorage("appTheme") private var storedTheme: AppTheme = .system {
        didSet {
            updateColorScheme()
        }
    }
    
    @Published var colorScheme: ColorScheme? = nil
    
    private init() {
        updateColorScheme()
    }
    
    var currentTheme: AppTheme {
        get { storedTheme }
        set {
            storedTheme = newValue
            updateColorScheme()
        }
    }
    
    private func updateColorScheme() {
        switch storedTheme {
        case .system:
            colorScheme = nil
        case .light:
            colorScheme = .light
        case .dark:
            colorScheme = .dark
        }
    }
    
    // Helper to get adaptive colors
    static func adaptiveColor(light: Color, dark: Color, colorScheme: ColorScheme?) -> Color {
        guard let scheme = colorScheme else {
            // System mode - use environment
            return light // Will be handled by SwiftUI's automatic adaptation
        }
        return scheme == .dark ? dark : light
    }
}

