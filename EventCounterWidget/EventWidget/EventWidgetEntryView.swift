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
        HStack(spacing: 12) {
            // Left: Circle Image with Icon Overlay
            ZStack(alignment: .bottomTrailing) {
                if let imageData = event.imageData, let uiImage = UIImage(data: imageData) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 50, height: 50)
                        .clipShape(Circle())
                    
                    // Category Icon Overlay
                    Image(systemName: event.categoryIcon)
                        .font(.system(size: 10, weight: .bold))
                        .foregroundStyle(.white)
                        .padding(3)
                        .background(Color(hex: event.colorHex).opacity(0.8))
                        .clipShape(Circle())
                        .offset(x: 4, y: 4)
                        .shadow(radius: 2)
                } else {
                    Circle()
                        .fill(.white.opacity(0.2))
                        .frame(width: 50, height: 50)
                    Image(systemName: event.categoryIcon)
                        .foregroundStyle(.white)
                        .font(.system(size: 20))
                }
            }
            
            // Right: Text & Countdown
            VStack(alignment: .leading, spacing: 4) {
                Text(event.title)
                    .font(.system(.subheadline, design: .rounded))
                    .fontWeight(.bold)
                    .foregroundStyle(.white)
                    .lineLimit(2)
                    .minimumScaleFactor(0.6)
                
                let components = CountdownService.calculateComponents(from: entryDate, to: event.date, isCountUp: event.isCountUp)
                
                if event.widgetDisplayStyle == "Progress" && !components.isPast {
                    HStack(spacing: 8) {
                        CircularProgressView(
                            progress: calculateProgress(from: event.createdAt, to: event.date),
                            color: .white,
                            lineWidth: 3,
                            showBackground: true
                        )
                        .frame(width: 20, height: 20)
                        
                        Text(components.formattedTitle)
                            .font(.system(.caption, design: .rounded))
                            .fontWeight(.bold)
                            .foregroundStyle(.white.opacity(0.9))
                    }
                } else {
                    if components.days > 0 || !components.isPast {
                        Text(components.formattedTitle)
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
            
            Spacer()
        }
        .padding(8)
    }
}

struct MediumEventView: View {
    let event: EventDTO
    var entryDate: Date
    
    var body: some View {
        HStack(spacing: 20) {
            // Left: Large Circle Image with Icon Overlay
            ZStack(alignment: .bottomTrailing) {
                if let imageData = event.imageData, let uiImage = UIImage(data: imageData) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 100, height: 100)
                        .clipShape(Circle())
                        .shadow(radius: 4)
                    
                    // Category Icon Overlay
                    Image(systemName: event.categoryIcon)
                        .font(.system(size: 18, weight: .bold))
                        .foregroundStyle(.white)
                        .padding(6)
                        .background(Color(hex: event.colorHex).opacity(0.8))
                        .clipShape(Circle())
                        .offset(x: 8, y: 8)
                        .shadow(radius: 4)
                } else {
                    Circle()
                        .fill(.white.opacity(0.2))
                        .frame(width: 100, height: 100)
                    Image(systemName: event.categoryIcon)
                        .foregroundStyle(.white)
                        .font(.system(size: 40))
                }
            }
            
            // Right: Content Section
            VStack(alignment: .leading, spacing: 6) {
                Text(event.title)
                    .font(.system(.title3, design: .rounded))
                    .fontWeight(.bold)
                    .foregroundStyle(.white)
                    .lineLimit(2)
                    .minimumScaleFactor(0.7)
                
                let components = CountdownService.calculateComponents(from: entryDate, to: event.date, isCountUp: event.isCountUp)
                
                if event.widgetDisplayStyle == "Progress" && !components.isPast {
                    HStack(spacing: 12) {
                        CircularProgressView(
                            progress: calculateProgress(from: event.createdAt, to: event.date),
                            color: .white,
                            lineWidth: 8,
                            showBackground: true
                        )
                        .frame(width: 40, height: 40)
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text(components.formattedTitle)
                                .font(.system(.headline, design: .rounded))
                                .fontWeight(.bold)
                                .foregroundStyle(.white)
                            
                            Text("\(Int(calculateProgress(from: event.createdAt, to: event.date) * 100))% Complete")
                                .font(.system(.caption2, design: .rounded))
                                .foregroundStyle(.white.opacity(0.6))
                        }
                    }
                } else {
                    if components.days > 0 {
                        Text(components.formattedTitle)
                            .font(.system(size: 24, weight: .black, design: .rounded))
                            .foregroundStyle(.white)
                            .minimumScaleFactor(0.8)
                    } else if !components.isPast || event.isCountUp {
                        Text(event.date, style: .timer)
                            .font(.system(.title2, design: .monospaced))
                            .fontWeight(.bold)
                            .foregroundStyle(.white)
                    } else {
                        Text("Event Completed")
                            .font(.system(.headline, design: .rounded))
                            .foregroundStyle(.white)
                    }
                }
                
                Text(event.date.formatted(date: .abbreviated, time: .omitted))
                    .font(.system(.caption, design: .rounded))
                    .foregroundStyle(.white.opacity(0.7))
            }
            
            Spacer()
        }
        .padding(16)
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
