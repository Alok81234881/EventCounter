import SwiftUI

// MARK: - Extracted Subviews

struct EventHeroImage: View {
    let event: Event
    
    var body: some View {
        GeometryReader { geometry in
            let minY = geometry.frame(in: .global).minY
            let size = geometry.size
            let height = size.height + (minY > 0 ? minY : 0)
            let yOffset = minY > 0 ? -minY : 0
            
            Group {
                if let imageData = event.imageData, let uiImage = UIImage(data: imageData) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                } else {
                    Rectangle()
                        .fill(Color(hex: event.colorHex) ?? .blue)
                }
            }
            .frame(width: size.width, height: height)
            .clipped()
            .offset(y: yOffset)
        }
        .frame(height: 300)
        .overlay(alignment: .bottomLeading) {
            // Title Overlay
            VStack(alignment: .leading, spacing: 4) {
                Text(event.title)
                    .font(.system(size: 32, weight: .bold))
                    .foregroundStyle(.white)
                
                Text(event.category.displayName)
                    .font(.system(size: 16))
                    .foregroundStyle(.white.opacity(0.8))
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 100)
            .allowsHitTesting(false)
        }
    }
}

struct EventCountdownCard: View {
    let event: Event
    let date: Date
    
    var body: some View {
        VStack(spacing: 16) {
            let components = CountdownService.calculateComponents(from: date, to: event.date, isCountUp: event.isCountUp)
            let timeUntil = event.date.timeIntervalSince(date)
            let thirtyDays: TimeInterval = 30 * 24 * 3600
            let oneDay: TimeInterval = 24 * 3600
            let themeColor = Color(hex: event.colorHex) ?? .purple
            
            HStack(spacing: 0) {
                if event.isCountUp {
                    if components.months > 0 {
                        CountdownUnitView(value: components.months, unit: "mo", color: themeColor, showPadding: false)
                        SeparatorView(color: themeColor)
                        CountdownUnitView(value: components.days, unit: "d", color: themeColor)
                        SeparatorView(color: themeColor)
                        CountdownUnitView(value: components.hours, unit: "h", color: themeColor)
                    } else if components.days > 0 {
                        CountdownUnitView(value: components.days, unit: "d", color: themeColor, showPadding: false)
                        SeparatorView(color: themeColor)
                        CountdownUnitView(value: components.hours, unit: "h", color: themeColor)
                        SeparatorView(color: themeColor)
                        CountdownUnitView(value: components.minutes, unit: "m", color: themeColor)
                    } else {
                        CountdownUnitView(value: components.hours, unit: "h", color: themeColor, showPadding: false)
                        SeparatorView(color: themeColor)
                        CountdownUnitView(value: components.minutes, unit: "m", color: themeColor)
                        SeparatorView(color: themeColor)
                        CountdownUnitView(value: components.seconds, unit: "s", color: themeColor)
                    }
                } else if timeUntil > thirtyDays {
                    CountdownUnitView(value: components.months, unit: "mo", color: themeColor, showPadding: false)
                    SeparatorView(color: themeColor)
                    CountdownUnitView(value: components.days, unit: "d", color: themeColor)
                    SeparatorView(color: themeColor)
                    CountdownUnitView(value: components.hours, unit: "h", color: themeColor)
                } else if timeUntil > oneDay {
                    CountdownUnitView(value: components.days, unit: "d", color: themeColor, showPadding: false)
                    SeparatorView(color: themeColor)
                    CountdownUnitView(value: components.hours, unit: "h", color: themeColor)
                    SeparatorView(color: themeColor)
                    CountdownUnitView(value: components.minutes, unit: "m", color: themeColor)
                } else if timeUntil > 0 {
                    CountdownUnitView(value: components.hours, unit: "h", color: themeColor, showPadding: false)
                    SeparatorView(color: themeColor)
                    CountdownUnitView(value: components.minutes, unit: "m", color: themeColor)
                    SeparatorView(color: themeColor)
                    CountdownUnitView(value: components.seconds, unit: "s", color: themeColor)
                } else {
                    Text("Event Completed")
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundStyle(themeColor)
                }
            }
            
            // Progress Bar Section
            HStack {
                Text("NOW")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(Color.adaptiveSecondaryText)
                
                Spacer()
                
                Text(event.date.formatted(.dateTime.month(.abbreviated).day()))
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(Color.adaptiveSecondaryText)
            }
            
            // Gradient Progress Bar
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(Color.adaptiveSecondaryText.opacity(0.2))
                    .frame(height: 8)
                
                Capsule()
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(hex: "#800080") ?? .purple,
                                .pink
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: max(8, UIScreen.main.bounds.width * 0.85 * event.progress), height: 8)
            }
            
            Text("\(Int(event.progress * 100))% of the wait is over!")
                .font(.system(size: 12))
                .foregroundStyle(Color.adaptiveSecondaryText)
        }
        .padding(24)
        .background(Color.adaptiveSecondaryBackground)
        .cornerRadius(24)
        .shadow(color: .black.opacity(0.1), radius: 20, y: 10)
        .padding(.horizontal, 20)
    }
}
