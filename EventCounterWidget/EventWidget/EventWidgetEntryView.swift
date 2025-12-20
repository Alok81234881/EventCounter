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
                    MediumEventView(event: event, entryDate: entry.date)
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
            // Icon or Image
            ZStack {
//                if let imageData = event.imageData, let uiImage = UIImage(data: imageData) {
//                    Image(uiImage: uiImage)
//                        .resizable()
//                        .scaledToFill()
//                        .frame(width: 40, height: 40)
//                        .clipShape(Circle())
//                } else {
                    Circle()
                        .fill(Color(event.colorHex) ?? .blue)
                        .opacity(0.2)
                        .frame(width: 40, height: 40)
                    Image(systemName: event.categoryIcon)
                        .foregroundStyle(Color(event.colorHex) ?? .blue)
                        .font(.system(size: 18))
               // }
            }
            
            // Name
            Text(event.title)
                .font(.headline)
                .lineLimit(2)
            
            // Date (No Timer)
            Label {
                Text(event.date.formatted(date: .abbreviated, time: .omitted))
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            } icon: {
                Image(systemName: "calendar")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
            
            let entryDate = Date() // Fallback for small view if not passed
            let components = CountdownService.calculateComponents(from: entryDate, to: event.date)

            if components.isPast {
                Text("Event Passed")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            } else if components.days > 0 {
                WidgetTimeUnitView(value: components.days, unit: "Days")
            } else {
                Text(event.date, style: .timer)
                    .font(.title3)
                    .bold()
                    .monospacedDigit()
                    .multilineTextAlignment(.center)
            }
            Spacer()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct MediumEventView: View {
    let event: EventDTO
    // Pass the entry date to ensure accurate snapshot calculation
    var entryDate: Date = Date()
    
    var body: some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading, spacing: 8) {
               // ZStack {
//                    if let imageData = event.imageData, let uiImage = UIImage(data: imageData) {
//                        Image(uiImage: uiImage)
//                            .resizable()
//                            .scaledToFill()
//                            .frame(width: 130, height: 130)
//                            //.clipShape(Circle())
//                            .padding(.top, 5)
//                    }
               // }
                
                Text(event.title)
                    .font(.system(size: 20))
                    .lineLimit(1)
                
                // Footer: Date
               
               // Spacer()
                
            }
            .padding(.bottom, 20)
            
            Spacer()
            
            // Card: "Time Remaining"
            // Use entryDate for widget snapshot consistency
            let components = CountdownService.calculateComponents(from: entryDate, to: event.date)
            
            VStack(spacing: 8) {
                Label {
                    Text(event.date.formatted(date: .abbreviated, time: .omitted))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                } icon: {
                    Image(systemName: "calendar")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                if components.isPast {
                    Text("Event Passed")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                } else {
                    Text("Time Remaining")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                        .textCase(.uppercase)
                }
                
                if components.isPast {
                    // Show nothing more if past
                    EmptyView()
                } else if components.days > 0 {
                    WidgetTimeUnitView(value: components.days, unit: "Days")
                } else {
                    Text(event.date, style: .timer)
                        .font(.title3)
                        .bold()
                        .monospacedDigit()
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
    SimpleEntry(date: .now, event: EventDTO.preview, futureEventCount: 6)
    SimpleEntry(date: .now, event: nil, futureEventCount: 7)
}

#Preview(as: .systemSmall) {
    EventWidget()
} timeline: {
    SimpleEntry(date: .now, event: EventDTO.preview, futureEventCount: 7)
}
