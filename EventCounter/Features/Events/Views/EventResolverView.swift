import SwiftUI
import SwiftData

struct EventResolverView: View {
    let eventID: UUID
    @Query private var events: [Event]
    
    init(eventID: UUID) {
        self.eventID = eventID
        let id = eventID
        _events = Query(filter: #Predicate<Event> { $0.id == id })
    }
    
    var body: some View {
        if let event = events.first {
            EventDetailView(event: event)
        } else {
            ContentUnavailableView(
                "Event Not Found",
                systemImage: "exclamationmark.triangle",
                description: Text("Required event could not be located.")
            )
        }
    }
}
