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
                            ZStack {
                                NavigationLink(destination: EventDetailView(event: event)) {
                                    EmptyView()
                                }
                                .opacity(0)
                                
                                EventCardView(event: event)
                            }
                            .listRowSeparator(.hidden)
                            .listRowBackground(Color.clear)
                            .listRowInsets(EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16))
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
