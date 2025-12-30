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
                Color(hex: event.colorHex)
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
        VStack(spacing: 8) {
            // Top: Circle Image with Icon Overlay (Centered)
            ZStack(alignment: .bottomTrailing) {
                if let imageData = event.imageData, let uiImage = UIImage(data: imageData) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 60, height: 60)
                        .clipShape(Circle())
                        .shadow(radius: 2)
                    
                    // Category Icon Overlay
                    Image(systemName: event.categoryIcon)
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(.white)
                        .padding(4)
                        .background(Color(hex: event.colorHex).opacity(0.8))
                        .clipShape(Circle())
                        .offset(x: 4, y: 4)
                        .shadow(radius: 2)
                } else {
                    Circle()
                        .fill(.white.opacity(0.2))
                        .frame(width: 60, height: 60)
                    Image(systemName: event.categoryIcon)
                        .foregroundStyle(.white)
                        .font(.system(size: 24))
                }
            }
            
            // Bottom: Text & Countdown (Centered)
            VStack(spacing: 2) {
                Text(event.title)
                    .font(.system(.subheadline, design: .rounded))
                    .fontWeight(.bold)
                    .foregroundStyle(.white)
                    .lineLimit(1)
                    .minimumScaleFactor(0.6)
                
                let components = CountdownService.calculateComponents(from: entryDate, to: event.date, isCountUp: event.isCountUp)
                
                if event.widgetDisplayStyle == "Progress" && !components.isPast {
                    HStack(spacing: 4) {
                        CircularProgressView(
                            progress: calculateProgress(from: event.createdAt, to: event.date),
                            color: .white,
                            lineWidth: 3,
                            showBackground: true
                        )
                        .frame(width: 16, height: 16)
                        
                        Text(components.formattedTitleShort)
                            .font(.system(.caption, design: .rounded))
                            .fontWeight(.bold)
                            .foregroundStyle(.white.opacity(0.9))
                    }
                    let components = CountdownService.calculateComponents(from: entryDate, to: event.date, isCountUp: event.isCountUp)
                    let timeUntil = event.date.timeIntervalSince(entryDate)
                    let thirtyDays: TimeInterval = 30 * 24 * 3600
                    let oneDay: TimeInterval = 24 * 3600
                    
                    if timeUntil > oneDay {
                        // > 1 Day: Show precise 3-component string (updates via Provider timeline)
                        Text(components.formattedThreeComponents)
                            .font(.system(size: 10, weight: .bold, design: .rounded))
                            .foregroundStyle(.white.opacity(0.9))
                            .lineLimit(1)
                            .minimumScaleFactor(0.8)
                    } else if timeUntil > 0 {
                        // < 1 day: Show Hours, Minutes, Seconds (Live)
                        Text(event.date, style: .timer)
                            .font(.system(.caption, design: .monospaced))
                            .fontWeight(.bold)
                            .foregroundStyle(.white.opacity(0.9))
                    } else if event.isCountUp {
                        Text(event.date, style: .timer)
                            .font(.system(.caption, design: .monospaced))
                            .fontWeight(.bold)
                            .foregroundStyle(.white.opacity(0.9))
                    } else {
                        Text("Done")
                            .font(.system(.caption, design: .rounded))
                            .fontWeight(.bold)
                            .foregroundStyle(.white.opacity(0.9))
                    }
                }
            }
        }
        
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(12)
        .widgetURL(URL(string: "eventcounter://event/\(event.id)"))
    }
}

struct MediumEventView: View {
    let event: EventDTO
    var entryDate: Date
    
    var body: some View {
        ZStack {
            // Background with slight blur effect (standard for widgets)
            Color.white.opacity(0.4)
            
            VStack(alignment: .leading, spacing: 0) {
                // Top Row: Icon, Title, Date and Status
                HStack(alignment: .top, spacing: 12) {
                    // Category Icon
                    ZStack {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(
                                LinearGradient(
                                    colors: [Color(hex: event.colorHex) ?? .blue, (Color(hex: event.colorHex) ?? .blue).opacity(0.8)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 48, height: 48)
                            .shadow(color: (Color(hex: event.colorHex) ?? .blue).opacity(0.3), radius: 4, y: 2)
                        
                        Image(systemName: event.categoryIcon)
                            .foregroundStyle(.white)
                            .font(.system(size: 22, weight: .semibold))
                    }
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text(event.title)
                            .font(.system(size: 18, weight: .bold, design: .rounded))
                            .foregroundStyle(Color(red: 0.1, green: 0.15, blue: 0.2))
                        
                        Text(event.date.formatted(date: .long, time: .omitted))
                            .font(.system(size: 13, weight: .medium, design: .rounded))
                            .foregroundStyle(Color.gray)
                    }
                    
                    Spacer()
                    
                    // Status dot
                    ZStack {
                        Circle()
                            .fill(Color(hex: event.colorHex).opacity(0.1) ?? .blue.opacity(0.1))
                            .frame(width: 24, height: 24)
                        Circle()
                            .fill(Color(hex: event.colorHex) ?? .blue)
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
                    
                    VStack(alignment: .leading, spacing: 4) {
                        if timeUntil > oneDay {
                            // > 1 Day: Precise 3-component display
                            Text(components.formattedThreeComponents)
                                .font(.system(size: 20, weight: .black, design: .rounded))
                                .foregroundStyle(Color(red: 0.1, green: 0.1, blue: 0.15))
                                .minimumScaleFactor(0.6)
                                .lineLimit(2)
                                .fixedSize(horizontal: false, vertical: true)
                        } else if timeUntil > 0 {
                            // < 1 day: Style for live seconds
                            Text(event.date, style: .timer)
                                .font(.system(size: 32, weight: .black, design: .monospaced))
                                .foregroundStyle(Color(red: 0.1, green: 0.1, blue: 0.15))
                                .minimumScaleFactor(0.5)
                        } else if event.isCountUp {
                            Text(event.date, style: .timer)
                                .font(.system(size: 32, weight: .black, design: .monospaced))
                                .foregroundStyle(Color(red: 0.1, green: 0.1, blue: 0.15))
                        } else {
                            Text("Event Completed")
                                .font(.system(size: 18, weight: .black, design: .rounded))
                                .foregroundStyle(Color(red: 0.1, green: 0.1, blue: 0.15))
                        }
                        
                        Text(timeUntil > 0 ? "remaining" : "elapsed")
                            .font(.system(size: 14, weight: .bold, design: .rounded))
                            .foregroundStyle(Color(hex: event.colorHex) ?? .cyan)
                    }
                    
                    Spacer()
                    
                    // Circular Progress
                    ZStack {
                        let progress = calculateProgress(from: event.createdAt, to: event.date)
                        CircularProgressView(
                            progress: progress,
                            color: Color(hex: event.colorHex) ?? .cyan,
                            lineWidth: 8,
                            showBackground: true
                        )
                        .frame(width: 54, height: 54)
                        
                        Text("\(Int(progress * 100))%")
                            .font(.system(size: 11, weight: .bold, design: .rounded))
                            .foregroundStyle(Color(red: 0.1, green: 0.15, blue: 0.2))
                    }
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 16)
            }
        }
        .containerBackground(for: .widget) {
            ZStack {
                Color.white
                // Subtle gradient to simulate glass reflection
                LinearGradient(
                    colors: [Color.white, Color.white.opacity(0.8)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            }
        }
        .widgetURL(URL(string: "eventcounter://event/\(event.id)"))
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
                } else if components.days > 0 {
                    Text(components.naturalDescription(category: category, title: event.title))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                } else {
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
