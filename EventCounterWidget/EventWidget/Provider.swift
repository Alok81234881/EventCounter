import WidgetKit
import SwiftUI
import SwiftData

struct Provider: TimelineProvider {
    @MainActor
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), event: EventDTO.preview, futureEventCount: 1)
    }

    @MainActor
    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let (event, count) = fetchNextEventAndCount()
        let entry = SimpleEntry(date: Date(), event: event, futureEventCount: count)
        completion(entry)
    }

    @MainActor
    func getTimeline(in context: Context, completion: @escaping (Timeline<SimpleEntry>) -> ()) {
        let (event, count) = fetchNextEventAndCount()
        
        // Pass the event date to the entry; the widget view will calculate the countdown itself.
        let entryDate = Date()
        let entry = SimpleEntry(date: entryDate, event: event, futureEventCount: count)

        // Only update timeline when explicitly requested (e.g., after event changes)
        let timeline = Timeline(entries: [entry], policy: .never)
        completion(timeline)
    }
    
    @MainActor
    private func fetchNextEventAndCount() -> (EventDTO?, Int) {
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
            let events = try container.mainContext.fetch(descriptor)
            
            print("[Widget] All events in store:")
            for event in events {
                print("- \(event.title): \(event.date) (isPinned: \(event.isPinned))")
            }
            
            let now = Date()
            
            // Strictly filter for future events
            let futureEvents = events.filter { $0.date > now }
            
            print("[Widget] Future events:")
            for event in futureEvents {
                print("- \(event.title): \(event.date) (isPinned: \(event.isPinned))")
            }
            
            // Priority Logic:
            // 1. First Pinned event in the future (nearest)
            // 2. Otherwise, first Unpinned event in the future (nearest)
            
            let pinnedUpcoming = futureEvents.filter { $0.isPinned }.sorted { $0.date < $1.date }
            let normalUpcoming = futureEvents.filter { !$0.isPinned }.sorted { $0.date < $1.date }
            
            if let event = pinnedUpcoming.first ?? normalUpcoming.first {
                print("[Widget] Selected event: \(event.title)")
                let dto = EventDTO(
                    title: event.title,
                    date: event.date,
                    categoryIcon: event.category.icon,
                    colorHex: event.colorHex
                   // imageData: event.imageData
                )
                return (dto, futureEvents.count)
            }
            return (nil, futureEvents.count)
        } catch {
            print("Widget Fetch Failed: \(error)")
            return (nil, 0)
        }
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
        EventDTO(title: "Mahima", date: Date().addingTimeInterval(4800), categoryIcon: "cake", colorHex: "#FF0000")
    }
}
