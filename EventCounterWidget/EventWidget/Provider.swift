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
            
            // Force sort in memory to be safe against SwiftData fetch quirks
            let sortedEvents = events.sorted { $0.date < $1.date }
            
            // Filter for future events
            let futureEvents = sortedEvents.filter { $0.date > Date() }
            
            // Logic: Pick nearest future event. If none, pick the most recent past event (last of sorted, filtered < Date, or just fallback).
            // Actually, if no future events, maybe show the one that JUST passed (sortedEvents.last)? 
            // The user didn't specify, but "first added" was the bug.
            // Let's stick to "Nearest Future" -> First of filtered.
            // Fallback: If no future, show the *next* occurring event (which helps if list is empty?) or maybe just the first one?
            // Original logic: futureEvents.first ?? events.first.
            
            if let event = futureEvents.first ?? sortedEvents.last { // Changed fallback to .last (most distant future? No, sortedEvents is ascending. .last is furthest future. events.first is oldest past. )
                // Wait, if no future events, maybe we want to show the Last Added? Or the one that was most recently passed?
                // Providing `sortedEvents.first` would be the OLDEST event.
                // Providing `sortedEvents.last` would be the LATEST event (furthest in future or most recent).
                // Let's stick to user request: "first upcoming". If none upcoming, maybe showed "No Upcoming" is better, but code handles nil elsewhere.
                // For now, robustly return nearest future.
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
