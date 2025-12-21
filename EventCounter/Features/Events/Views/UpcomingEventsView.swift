import SwiftUI
import SwiftData
import WidgetKit

struct UpcomingEventsView: View {
    @Query(sort: \Event.date) private var events: [Event]
    @Environment(\.modelContext) private var modelContext
    @State private var showingAddEvent = false

    private var upcomingEvents: [Event] {
        events.filter { $0.date > .now }
    }

    var body: some View {
        NavigationStack {
            TimelineView(.periodic(from: .now, by: 1.0)) { timeline in
                let upcoming = events.filter { $0.date > timeline.date }
                
                List {
                    if upcoming.isEmpty {
                        ContentUnavailableView(
                            "No Upcoming Events",
                            systemImage: "calendar.badge.plus",
                            description: Text("Add your first countdown to get started!")
                        )
                    } else {
                        ForEach(upcoming) { event in
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
                            deleteItems(offsets: offsets, from: upcoming)
                        }
                    }
                }
            }
            .navigationTitle("Upcoming")
            .toolbar {
                ToolbarItem {
                    Button(action: { showingAddEvent = true }) {
                        Label("Add Item", systemImage: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddEvent) {
                AddEventView()
            }
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
