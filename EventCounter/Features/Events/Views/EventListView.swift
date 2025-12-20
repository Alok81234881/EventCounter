import SwiftUI
import SwiftData
import Foundation
import WidgetKit

struct EventListView: View {
    @Query(sort: \Event.date) private var events: [Event]
    @Environment(\.modelContext) private var modelContext
    @State private var showingAddEvent = false

    private func upcomingEvents(at date: Date) -> [Event] {
        events.filter { $0.date > date }
    }
    
    private func passedEvents(at date: Date) -> [Event] {
        // Show recent passed events first
        events.filter { $0.date <= date }.reversed()
    }

    var body: some View {
        NavigationStack {
            TimelineView(.periodic(from: .now, by: 1.0)) { timeline in
                let now = timeline.date
                let upcoming = upcomingEvents(at: now)
                let passed = passedEvents(at: now)
                
                List {
                    if !upcoming.isEmpty {
                        Section("Upcoming Events") {
                            ForEach(upcoming) { event in
                                NavigationLink {
                                    EventDetailView(event: event)
                                } label: {
                                    EventCardView(event: event)
                                }
                            }
                            .onDelete { offsets in
                                deleteItems(offsets: offsets, from: upcoming)
                            }
                        }
                    }
                    
                    if !passed.isEmpty {
                        Section("Passed Events") {
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
                    
                    if upcoming.isEmpty && passed.isEmpty {
                        ContentUnavailableView(
                            "No Events",
                            systemImage: "calendar.badge.plus",
                            description: Text("Tap the + button to add your first countdown!")
                        )
                    }
                }
            }
            .navigationTitle("Events")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    NavigationLink(destination: SettingsView()) {
                        Image(systemName: "gear")
                    }
                }
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

extension EventListView {
    static let mockEvents: [Event] = [
        Event(title: "Birthday Party", date: .now, note: "Bring cake", category: .birthday, colorHex: "#FF69B4", isPinned: true, notifyBefore: nil),
        Event(title: "Exam Day", date: .now.addingTimeInterval(86400), note: "Maths final", category: .exam, colorHex: "#4287f5", isPinned: false, notifyBefore: nil)
    ]
}
//
#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Event.self, configurations: config)
    
    // Seed data
    let mockEvents = EventListView.mockEvents
    for event in mockEvents {
        container.mainContext.insert(event)
    }
    
    return EventListView()
        .modelContainer(container)
}
