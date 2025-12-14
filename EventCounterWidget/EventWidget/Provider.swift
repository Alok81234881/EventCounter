import WidgetKit
import SwiftUI
import SwiftData

struct Provider: TimelineProvider {
    @MainActor
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), event: EventDTO.preview)
    }

    @MainActor
    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = SimpleEntry(date: Date(), event: fetchNextEvent())
        completion(entry)
    }

    @MainActor
    func getTimeline(in context: Context, completion: @escaping (Timeline<SimpleEntry>) -> ()) {
        let event = fetchNextEvent()
        let entryDate = Date()
        
        // Update every minute to keep countdown relatively fresh
        let nextUpdateDate = Calendar.current.date(byAdding: .minute, value: 1, to: entryDate)!
        let entry = SimpleEntry(date: entryDate, event: event)

        let timeline = Timeline(entries: [entry], policy: .after(nextUpdateDate))
        completion(timeline)
    }
    
    @MainActor
    private func fetchNextEvent() -> EventDTO? {
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
            
            // Filter for future events
            let futureEvents = events.filter { $0.date > Date() }
            if let event = futureEvents.first ?? events.first {
                // Map to DTO immediately on Main Actor while Context is valid
                return EventDTO(
                    title: event.title, 
                    date: event.date, 
                    categoryIcon: event.category.icon, 
                    colorHex: event.colorHex
                )
            }
            return nil
        } catch {
            print("Widget Fetch Failed: \(error)")
            return nil
        }
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let event: EventDTO?
}

// Mock extension for preview
extension EventDTO {
    static var preview: EventDTO {
        EventDTO(title: "Mahima", date: Date().addingTimeInterval(4800), categoryIcon: "cake", colorHex: "#FF0000")
    }
}
