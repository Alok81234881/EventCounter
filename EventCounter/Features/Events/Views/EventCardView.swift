import SwiftUI
import Foundation


struct EventCardView: View {
    let event: Event
    
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        let accentColor = Color(hex: event.colorHex) ?? Color.accentColor
        
        HStack(spacing: 0) {
            // Vertical Accent Bar
            Rectangle()
                .fill(accentColor)
                .frame(width: 4)
            
            HStack(spacing: 16) {
                // Icon/Image Section
                ZStack {
                    if let imageData = event.imageData, let uiImage = UIImage(data: imageData) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 48, height: 48)
                            .clipShape(Circle())
                    } else {
                        Circle()
                            .fill(accentColor.opacity(0.1))
                            .frame(width: 48, height: 48)
                        
                        Image(systemName: event.category.icon)
                            .font(.system(size: 20))
                            .foregroundStyle(accentColor)
                    }
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(event.title)
                        .font(.headline)
                        .foregroundStyle(.primary)
                    
                    if event.isCountUp && event.date <= .now {
                        let components = CountdownService.calculateComponents(from: .now, to: event.date, isCountUp: true)
                        Text(components.naturalDescription(category: event.category, title: event.title))
                            .font(.caption)
                            .foregroundStyle(accentColor)
                            .bold()
                    } else {
                        Text(event.date, style: .date)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }
                
                Spacer()
                
                if event.isPinned {
                    Image(systemName: "pin.fill")
                        .font(.caption)
                        .foregroundStyle(Color(hex: "#800080") ?? .purple)
                        .padding(6)
                        .background(.ultraThinMaterial)
                        .clipShape(Circle())
                }
                
                // Progress Ring
                if event.date > .now {
                    CircularProgressView(
                        progress: event.progress,
                        color: accentColor,
                        lineWidth: 8,
                        showBackground: true
                    )
                    .frame(width: 30, height: 30)
                }
            }
            .padding(16)
        }
        .background(Color(uiColor: .secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .padding(.vertical, 4)
    }
}

// Helper for Color from Hex
extension Color {
    init?(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")

        var rgb: UInt64 = 0

        var r: CGFloat = 0.0
        var g: CGFloat = 0.0
        var b: CGFloat = 0.0
        var a: CGFloat = 1.0

        let length = hexSanitized.count

        guard Scanner(string: hexSanitized).scanHexInt64(&rgb) else { return nil }

        if length == 6 {
            r = CGFloat((rgb & 0xFF0000) >> 16) / 255.0
            g = CGFloat((rgb & 0x00FF00) >> 8) / 255.0
            b = CGFloat(rgb & 0x0000FF) / 255.0

        } else if length == 8 {
            r = CGFloat((rgb & 0xFF000000) >> 24) / 255.0
            g = CGFloat((rgb & 0x00FF0000) >> 16) / 255.0
            b = CGFloat((rgb & 0x0000FF00) >> 8) / 255.0
            a = CGFloat(rgb & 0x000000FF) / 255.0

        } else {
            return nil
        }

        self.init(red: r, green: g, blue: b, opacity: a)
    }
}
