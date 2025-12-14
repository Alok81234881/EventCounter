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
                    SmallEventView(event: event)
                case .systemMedium:
                    MediumEventView(event: event)
                default:
                    SmallEventView(event: event)
                }
            }
            .padding()
            .containerBackground(for: .widget) {
                Color(uiColor: .systemBackground)
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
            .containerBackground(Color(uiColor: .systemBackground), for: .widget)
        }
    }
}

struct SmallEventView: View {
    let event: EventDTO
    
    var body: some View {
        VStack(alignment: .center, spacing: 8) {
            // Icon
            ZStack {
                Circle()
                    .fill(Color(event.colorHex) ?? .blue)
                    .opacity(0.2)
                    .frame(width: 40, height: 40)
                Image(systemName: event.categoryIcon)
                    .foregroundStyle(Color(event.colorHex) ?? .blue)
                    .font(.system(size: 18))
            }
            
          
            
            // Name
            Text(event.title)
                .font(.headline)
                .lineLimit(2)
            
            // Date (No Timer)
            Label {
                Text(event.date.formatted(date: .abbreviated, time: .omitted))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            } icon: {
                Image(systemName: "calendar")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding(.leading , -10)
            Spacer()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct MediumEventView: View {
    let event: EventDTO
    
    var body: some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading, spacing: 8) {
                ZStack {
                    Circle()
                        .fill(Color(event.colorHex) ?? .blue)
                        .opacity(0.2)
                        .frame(width: 32, height: 32)
                    Image(systemName: event.categoryIcon)
                        .foregroundStyle(Color(event.colorHex) ?? .blue)
                        .font(.system(size: 14))
                }
                
                Text(event.title)
                    .font(.system(size: 20))
                    .lineLimit(1)
                
                // Footer: Date
                Label {
                    Text(event.date.formatted(date: .abbreviated, time: .omitted))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                } icon: {
                    Image(systemName: "calendar")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                
            }
            .padding(.bottom, 20)
            
            Spacer()
            
            // Card: "Time Remaining"
            let components = CountdownService.calculateComponents(from: Date(), to: event.date)
            
            VStack(spacing: 8) {
                Text(components.isPast ? "Event Passed" : "Time Remaining")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                    .textCase(.uppercase)
                
                HStack(spacing: 12) {
                    WidgetTimeUnitView(value: components.days, unit: "Days")
                    WidgetTimeUnitView(value: components.hours, unit: "Hrs")
                    WidgetTimeUnitView(value: components.minutes, unit: "Mins")
                }
            }
            .frame(width: 150, height: 90)
            .background(Color(uiColor: .secondarySystemBackground))
            .cornerRadius(12)
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
    SimpleEntry(date: .now, event: EventDTO.preview)
    SimpleEntry(date: .now, event: nil)
}

#Preview(as: .systemSmall) {
    EventWidget()
} timeline: {
    SimpleEntry(date: .now, event: EventDTO.preview)
}
