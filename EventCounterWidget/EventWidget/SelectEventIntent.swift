import AppIntents
import SwiftData
import Foundation

struct SelectEventIntent: WidgetConfigurationIntent {
    static var title: LocalizedStringResource = "Select Event"
    static var description: LocalizedStringResource = "Choose an event to track."

    @Parameter(title: "Event")
    var event: EventEntity?
}

struct EventEntity: AppEntity {
    let id: UUID
    let title: String
    
    static var typeDisplayRepresentation: TypeDisplayRepresentation = "Event"
    static var defaultQuery = EventQuery()
    
    var displayRepresentation: DisplayRepresentation {
        DisplayRepresentation(title: "\(title)")
    }
}

struct EventQuery: EntityQuery {
    func entities(for identifiers: [UUID]) async throws -> [EventEntity] {
        let events = try await fetchEvents()
        return events.filter { identifiers.contains($0.id) }
            .map { EventEntity(id: $0.id, title: $0.title) }
    }
    
    func suggestedEntities() async throws -> [EventEntity] {
        let events = try await fetchEvents()
        return events.map { EventEntity(id: $0.id, title: $0.title) }
    }
    
    func defaultResult() async throws -> EventEntity? {
        try await suggestedEntities().first
    }
    
    private func fetchEvents() async throws -> [Event] {
        let schema = Schema([Event.self])
        let appGroupURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.com.alok.singh.EventCounter")!
        let storeURL = appGroupURL.appendingPathComponent("EventCout.sqlite")
        let modelConfiguration = ModelConfiguration(schema: schema, url: storeURL)
        
        let container = try ModelContainer(for: schema, configurations: [modelConfiguration])
        let context = ModelContext(container)
        
        let descriptor = FetchDescriptor<Event>(sortBy: [SortDescriptor(\.date)])
        return try context.fetch(descriptor)
    }
}
