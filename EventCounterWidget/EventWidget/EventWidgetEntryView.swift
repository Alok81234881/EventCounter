import SwiftUI
import WidgetKit

struct EventWidgetEntryView : View {
    var entry: Provider.Entry
    @Environment(\.widgetFamily) var family

    var body: some View {
        if let event = entry.event {
            Group {
                switch family {
                case .systemSmall:
                    SmallEventView(event: event, entryDate: entry.date)
                case .systemMedium:
                    MediumEventView(event: event, entryDate: entry.date)
                case .accessoryCircular:
                    AccessoryCircularView(event: event)
                case .accessoryRectangular:
                    AccessoryRectangularView(event: event)
                case .accessoryInline:
                    AccessoryInlineView(event: event)
                default:
                    SmallEventView(event: event, entryDate: entry.date)
                }
            }
            .containerBackground(for: .widget) {
                ZStack {
                    Color(uiColor: .systemBackground)
                    // Subtle background gradient to match the "glass" look from the image
                    LinearGradient(
                        colors: [
                            Color(uiColor: .systemBackground),
                            Color(uiColor: .secondarySystemBackground).opacity(0.8),
                            Color(uiColor: .tertiarySystemBackground).opacity(0.6)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                }
            }
        } else {
            VStack {
                Text("No Upcoming Events")
                    .font(.headline)
                Text("Add an event in the app to see it here.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
            .padding()
            .containerBackground(for: .widget) {
                Color(uiColor: .systemBackground)
            }
        }
    }
}

struct SmallEventView: View {
    let event: EventDTO
    var entryDate: Date
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Top Row: Category Icon & Countdown
            HStack(alignment: .top) {
                // Category Icon (Rounded Rectangle with Gradient)
                ZStack {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(
                            LinearGradient(
                                colors: [Color(hex: event.colorHex), Color(hex: event.colorHex).opacity(0.8)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 50, height: 50)
                        .shadow(color: Color(hex: event.colorHex).opacity(0.3), radius: 6, y: 3)
                    
                    Image(systemName: event.categoryIcon)
                        .foregroundStyle(.white)
                        .font(.system(size: 24, weight: .semibold))
                }
                
                Spacer()
                
                // Countdown Value & Label (Unit-Based)
                let components = CountdownService.calculateComponents(from: entryDate, to: event.date, isCountUp: event.isCountUp)
                let info = getUnitInfo(for: components, entryDate: entryDate, targetDate: event.date)
                
                VStack(alignment: .trailing, spacing: -2) {
                    Text(info.value)
                        .font(.system(size: 32, weight: .black, design: .rounded))
                        .foregroundStyle(Color.primary)
                    
                    Text(info.label)
                        .font(.system(size: 10, weight: .bold, design: .rounded))
                        .foregroundStyle(Color.secondary)
                        .tracking(1)
                }
            }
            
            Spacer()
            
            // Bottom Row: Title and Date
            VStack(alignment: .leading, spacing: 2) {
                Text(event.title)
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.primary)
                    .lineLimit(2)
                    .minimumScaleFactor(0.8)
                
                Text(event.date.formatted(.dateTime.month().day()))
                    .font(.system(size: 13, weight: .medium, design: .rounded))
                    .foregroundStyle(Color.secondary)
            }
        }
        .padding(10)
        .widgetURL(URL(string: "eventcounter://event/\(event.id)"))
    }
    
    private func getUnitInfo(for components: CountdownComponents, entryDate: Date, targetDate: Date) -> (value: String, label: String) {
        let timeInterval = targetDate.timeIntervalSince(entryDate)
        
        if timeInterval <= 0 && !event.isCountUp {
            return ("0", "SEC")
        }
        
        // Use abs for count-up support
        let absInterval = abs(timeInterval)
        
        if absInterval >= 24 * 3600 {
            let totalDays = (components.months * 30) + components.days
            return ("\(totalDays)", totalDays == 1 ? "DAY" : "DAYS")
        } else if absInterval >= 3600 {
            return ("\(components.hours)", components.hours == 1 ? "HR" : "HRS")
        } else if absInterval >= 60 {
            return ("\(components.minutes)", "MIN")
        } else {
            return ("\(components.seconds)", "SEC")
        }
    }
}

struct MediumEventView: View {
    let event: EventDTO
    var entryDate: Date
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Top Row: Icon, Title, Date and Status
            HStack(alignment: .top, spacing: 12) {
                // Category Icon (White icon on colored background as in image)
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(
                            LinearGradient(
                                colors: [Color(hex: event.colorHex), Color(hex: event.colorHex).opacity(0.8)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 44, height: 44)
                        .shadow(color: Color(hex: event.colorHex).opacity(0.3), radius: 4, y: 2)
                    
                    Image(systemName: event.categoryIcon)
                        .foregroundStyle(.white)
                        .font(.system(size: 20, weight: .semibold))
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(event.title)
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundStyle(Color.primary)
                    
                    Text(event.date.formatted(date: .long, time: .omitted))
                        .font(.system(size: 13, weight: .medium, design: .rounded))
                        .foregroundStyle(Color.secondary)
                }
                
                Spacer()
                
                // Status dot (Matching image style)
                ZStack {
                    Circle()
                        .fill(Color(hex: event.colorHex).opacity(0.1))
                        .frame(width: 28, height: 28)
                    Circle()
                        .fill(Color(hex: event.colorHex))
                        .frame(width: 8, height: 8)
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 16)
            
            Spacer()
            
            // Bottom Row: Countdown and Progress
            HStack(alignment: .bottom) {
                let components = CountdownService.calculateComponents(from: entryDate, to: event.date, isCountUp: event.isCountUp)
                let timeUntil = event.date.timeIntervalSince(entryDate)
                let thirtyDays: TimeInterval = 30 * 24 * 3600
                let oneDay: TimeInterval = 24 * 3600
                
                VStack(alignment: .leading, spacing: 0) {
                    if timeUntil > transitionToSmallTimerThreshold() {
                        // Matching the "14 DAYS" large style from the image
                        HStack(alignment: .firstTextBaseline, spacing: 4) {
                            Text(primaryUnitValue(for: components))
                                .font(.system(size: 48, weight: .black, design: .rounded))
                                .foregroundStyle(Color.primary)
                            
                            Text(primaryUnitLabel(for: components).uppercased())
                                .font(.system(size: 14, weight: .bold, design: .rounded))
                                .foregroundStyle(Color(hex: event.colorHex))
                        }
                        
                        Text(secondaryUnitsDescription(for: components))
                            .font(.system(size: 14, weight: .bold, design: .rounded))
                            .foregroundStyle(Color.secondary)
                            .padding(.top, -4)
                    } else if timeUntil > 0 {
                        // Final 24 hours: Live timer
                        Text(event.date, style: .timer)
                            .font(.system(size: 32, weight: .black, design: .monospaced))
                            .foregroundStyle(Color.primary)
                            .minimumScaleFactor(0.5)
                        
                        Text("remaining")
                            .font(.system(size: 14, weight: .bold, design: .rounded))
                            .foregroundStyle(Color(hex: event.colorHex))
                    } else if event.isCountUp {
                        Text(event.date, style: .timer)
                            .font(.system(size: 32, weight: .black, design: .monospaced))
                            .foregroundStyle(Color.primary)
                        
                        Text("elapsed")
                            .font(.system(size: 14, weight: .bold, design: .rounded))
                            .foregroundStyle(Color(hex: event.colorHex))
                    } else {
                        Text("Event Completed")
                            .font(.system(size: 18, weight: .black, design: .rounded))
                            .foregroundStyle(Color.primary)
                    }
                }
                
                Spacer()
                
                // Circular Progress (Matching image size and style)
                ZStack {
                    let progress = calculateProgress(from: event.createdAt, to: event.date)
                    CircularProgressView(
                        progress: progress,
                        color: Color(hex: event.colorHex),
                        lineWidth: 6,
                        showBackground: true
                    )
                    .frame(width: 50, height: 50)
                    
                    Text("\(Int(progress * 100))%")
                        .font(.system(size: 12, weight: .bold, design: .rounded))
                        .foregroundStyle(Color.primary)
                }
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 16)
        }
        .widgetURL(URL(string: "eventcounter://event/\(event.id)"))
    }
    
    // Helper to decide when to switch to the big numeric style vs the timer
    private func transitionToSmallTimerThreshold() -> TimeInterval {
        return 24 * 3600 // 1 day
    }
    
    private func primaryUnitValue(for components: CountdownComponents) -> String {
        if components.months > 0 { return "\(components.months)" }
        return "\(components.days)"
    }
    
    private func primaryUnitLabel(for components: CountdownComponents) -> String {
        if components.months > 0 { return components.months == 1 ? "Month" : "Months" }
        return components.days == 1 ? "Day" : "Days"
    }
    
    private func secondaryUnitsDescription(for components: CountdownComponents) -> String {
        if components.months > 0 {
            return "\(components.days)d \(components.hours)h remaining"
        } else {
            return "\(components.hours)h \(components.minutes)m remaining"
        }
    }
}


struct AccessoryCircularView: View {
    let event: EventDTO
    
    var body: some View {
        ZStack {
            AccessoryWidgetBackground()
            VStack(spacing: 0) {
                Image(systemName: event.categoryIcon)
                    .font(.system(size: 14))
                
                let components = CountdownService.calculateComponents(from: Date(), to: event.date, isCountUp: event.isCountUp)
                let category = EventCategory(rawValue: event.categoryRaw) ?? .personal
                if components.isPast && !event.isCountUp {
                    Text("Done")
                        .font(.system(size: 10))
                } else if components.days > 0 {
                    Text("\(components.days)d")
                        .font(.system(size: 10, weight: .bold))
                } else {
                    Text(event.date, style: .timer)
                        .font(.system(size: 10))
                        .minimumScaleFactor(0.5)
                }
            }
        }
        .widgetURL(URL(string: "eventcounter://event/\(event.id)"))
    }
}

struct AccessoryRectangularView: View {
    let event: EventDTO
    
    var body: some View {
        HStack(spacing: 8) {
            VStack(alignment: .leading, spacing: 2) {
                Label {
                    Text(event.title)
                        .font(.headline)
                        .widgetAccentable()
                        .minimumScaleFactor(0.7)
                } icon: {
                    Image(systemName: event.categoryIcon)
                }
                
                let components = CountdownService.calculateComponents(from: Date(), to: event.date, isCountUp: event.isCountUp)
                let category = EventCategory(rawValue: event.categoryRaw) ?? .personal
                if components.isPast && !event.isCountUp {
                    Text("Event Passed")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
//                else if components.days > 0 {
//                    Text(components.naturalDescription(category: category, title: event.title))
//                        .font(.caption)
//                        .foregroundStyle(.secondary)
//                }
                else {
                    Text(event.date, style: .timer)
                        .font(.system(.body, design: .monospaced))
                        .foregroundStyle(.secondary)
                }
            }
            Spacer()
        }
        .widgetURL(URL(string: "eventcounter://event/\(event.id)"))
    }
}

struct AccessoryInlineView: View {
    let event: EventDTO
    
    var body: some View {
        let components = CountdownService.calculateComponents(from: Date(), to: event.date)
        ViewThatFits {
            Text("\(event.title): \(components.formattedTitle)")
            Text("\(event.title): \(components.days)d")
        }
        .widgetURL(URL(string: "eventcounter://event/\(event.id)"))
    }
}

struct WidgetTimeUnitView: View {
    let value: Int
    let unit: String
    
    var body: some View {
        VStack(spacing: 2) {
            Text("\(value)")
                .font(.title3)
                .bold()
                .monospacedDigit()
                .lineLimit(1)
                .minimumScaleFactor(0.8)
            Text(unit)
                .font(.system(size: 10))
                .foregroundStyle(.secondary)
        }
        .frame(minWidth: 30)
    }
}

#Preview(as: .systemMedium) {
    EventWidget()
} timeline: {
    SimpleEntry(date: .now, event: EventDTO.preview, futureEventCount: 6)
    SimpleEntry(date: .now, event: nil, futureEventCount: 7)
}



// MARK: - Shared Views

struct CircularProgressView: View {
    let progress: Double
    let color: Color
    var lineWidth: CGFloat = 8
    var showBackground: Bool = true
    
    var body: some View {
        ZStack {
            if showBackground {
                Circle()
                    .stroke(color.opacity(0.2), lineWidth: lineWidth)
            }
            Circle()
                .trim(from: 0, to: CGFloat(min(progress, 1.0)))
                .stroke(color, style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
                .rotationEffect(.degrees(-90))
        }
    }
}

func calculateProgress(from createdAt: Date, to targetDate: Date) -> Double {
    let total = targetDate.timeIntervalSince(createdAt)
    guard total > 0 else { return 1.0 }
    let elapsed = Date().timeIntervalSince(createdAt)
    return min(max(elapsed / total, 0.0), 1.0)
}
