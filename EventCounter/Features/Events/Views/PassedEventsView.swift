import SwiftUI
import SwiftData
import WidgetKit

struct PassedEventsView: View {
    @Query(sort: \Event.date, order: .reverse) private var events: [Event]
    @Environment(\.modelContext) private var modelContext

    var body: some View {
        NavigationStack {
            TimelineView(.periodic(from: .now, by: 1.0)) { timeline in
                let passed = events.filter { $0.date <= timeline.date }
                
                List {
                    if passed.isEmpty {
                        ContentUnavailableView(
                            "No Passed Events",
                            systemImage: "clock.arrow.circlepath",
                            description: Text("Events will appear here after they happen.")
                        )
                    } else {
                        ForEach(passed) { event in
                            NavigationLink {
                                EventDetailView(event: event)
                            } label: {
                                EventCardView(event: event)
                            }
                        }
                        .onDelete { offsets in
                            deleteItems(offsets: offsets, from: passed)
                        }
                    }
                }
            }
            .navigationTitle("Passed")
        }
    }

    private func deleteItems(offsets: IndexSet, from dataSource: [Event]) {
        withAnimation {
            for index in offsets {
                let eventToDelete = dataSource[index]
                modelContext.delete(eventToDelete)
            }
            try? modelContext.save()
            WidgetCenter.shared.reloadAllTimelines()
        }
    }
}
