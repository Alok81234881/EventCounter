import WidgetKit
import SwiftUI
import SwiftData
import UIKit

struct Provider: TimelineProvider {
    @MainActor
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), event: EventDTO.preview, futureEventCount: 1)
    }

    @MainActor
    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let (event, count) = fetchNextEventAndCount(for: context.family)
        let entry = SimpleEntry(date: Date(), event: event, futureEventCount: count)
        completion(entry)
    }

    @MainActor
    func getTimeline(in context: Context, completion: @escaping (Timeline<SimpleEntry>) -> ()) {
        let (event, count) = fetchNextEventAndCount(for: context.family)
        
        let entryDate = Date()
        let entry = SimpleEntry(date: entryDate, event: event, futureEventCount: count)

        // Refresh the timeline as soon as the current event passes (if it's a countdown)
        // Milestones (count-ups) don't need a specific refresh unless we want to be precise.
        let reloadDate = event?.date ?? Calendar.current.date(byAdding: .hour, value: 1, to: entryDate)!
        let timeline = Timeline(entries: [entry], policy: .after(reloadDate))
        completion(timeline)
    }
    
    @MainActor
    private func fetchNextEventAndCount(for family: WidgetFamily) -> (EventDTO?, Int) {
        // Shared Model Container Logic
        let schema = Schema([Event.self])
        
        let modelConfiguration: ModelConfiguration
        if let appGroupURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.com.alok.singh.EventCounter") {
             let storeURL = appGroupURL.appendingPathComponent("EventCout.sqlite")
             modelConfiguration = ModelConfiguration(schema: schema, url: storeURL)
        } else {
             modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        }

        do {
            let container = try ModelContainer(for: schema, configurations: [modelConfiguration])
            let descriptor = FetchDescriptor<Event>(
                sortBy: [SortDescriptor(\.date, order: .forward)]
            )
            let allEvents = try container.mainContext.fetch(descriptor)
            let now = Date()
            
            let futureEvents = allEvents.filter { $0.date > now }
            let pastEvents = allEvents.filter { $0.date <= now }
            
            var selectedEvent: Event?
            
            switch family {
            case .systemSmall:
                // Small Widget: Show most recent PAST event
                selectedEvent = pastEvents.sorted(by: { $0.date > $1.date }).first
            case .systemMedium:
                // Medium Widget: Show next UPCOMING event
                selectedEvent = futureEvents.sorted(by: { $0.date < $1.date }).first
            default:
                // Lock Screen: Prioritize pinned, then upcoming
                selectedEvent = allEvents.filter { $0.isPinned }.sorted(by: { abs($0.date.timeIntervalSince(now)) < abs($1.date.timeIntervalSince(now)) }).first 
                    ?? futureEvents.first
            }
            
            if let event = selectedEvent {
                var resizedImageData: Data? = nil
                if let originalData = event.imageData {
                    resizedImageData = resizeImage(data: originalData, targetSize: CGSize(width: 300, height: 300))
                }
                
                let dto = EventDTO(
                    title: event.title,
                    date: event.date,
                    categoryIcon: event.category.icon,
                    colorHex: event.colorHex,
                    imageData: resizedImageData,
                    isCountUp: event.isCountUp,
                    categoryRaw: event.category.rawValue,
                    widgetDisplayStyle: event.widgetDisplayStyle.rawValue,
                    createdAt: event.createdAt,
                    id: event.id.uuidString
                )
                
                // Count relevant events based on logic
                let relevantCount = (family == .systemSmall) ? pastEvents.count : futureEvents.count
                return (dto, relevantCount)
            }
            return (nil, 0)
        } catch {
            print("Widget Fetch Failed: \(error)")
            return (nil, 0)
        }
    }

    private func resizeImage(data: Data, targetSize: CGSize) -> Data? {
        guard let image = UIImage(data: data) else { return nil }
        
        let widthRatio  = targetSize.width  / image.size.width
        let heightRatio = targetSize.height / image.size.height
        
        var newSize: CGSize
        if(widthRatio > heightRatio) {
            newSize = CGSize(width: image.size.width * heightRatio, height: image.size.height * heightRatio)
        } else {
            newSize = CGSize(width: image.size.width * widthRatio,  height: image.size.height * widthRatio)
        }
        
        let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
        
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage?.jpegData(compressionQuality: 0.7)
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let event: EventDTO?
    let futureEventCount: Int // This can be used in the view to show how many future events exist
}

// Mock extension for preview
extension EventDTO {
    static var preview: EventDTO {
        EventDTO(title: "Mahima", date: Date().addingTimeInterval(4800), categoryIcon: "cake", colorHex: "#FF0000", imageData: nil, isCountUp: false, categoryRaw: "anniversary", widgetDisplayStyle: "Timer", createdAt: Date().addingTimeInterval(-3600), id: UUID().uuidString)
    }
}
