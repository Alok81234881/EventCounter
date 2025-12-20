import Foundation
import Combine
import EventKit

@MainActor
class CalendarService: ObservableObject {
    static let shared = CalendarService()
    private let eventStore = EKEventStore()
    
    private init() {}
    
    func requestAccess() async -> Bool {
        do {
            // Use the modern requestFullAccessToEvents API for iOS 17+
            if #available(iOS 17.0, *) {
                return try await eventStore.requestFullAccessToEvents()
            } else {
                // Fallback for older versions
                return try await eventStore.requestAccess(to: .event)
            }
        } catch {
            print("[CalendarService] Error requesting access: \(error.localizedDescription)")
            return false
        }
    }
    
    func fetchUpcomingEvents() async -> [EKEvent] {
        let hasAccess = await requestAccess()
        guard hasAccess else { return [] }
        
        let now = Date()
        let oneYearFromNow = Calendar.current.date(byAdding: .year, value: 1, to: now)!
        
        let predicate = eventStore.predicateForEvents(withStart: now, end: oneYearFromNow, calendars: nil)
        let events = eventStore.events(matching: predicate)
        
        // Sort by date and filter out all-day events if they are in the past
        return events.filter { $0.startDate > now }.sorted { $0.startDate < $1.startDate }
    }
}
