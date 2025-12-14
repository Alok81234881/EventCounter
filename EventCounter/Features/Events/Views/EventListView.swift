import SwiftUI
import SwiftData
import Foundation

struct EventListView: View {
    @Query() private var events: [Event]
    @Environment(\.modelContext) private var modelContext
    @State private var showingAddEvent = false

    @State private var showingSettings = false

    var body: some View {
        NavigationStack {
            List {
                ForEach(events) { event in
                    NavigationLink {
                        EventDetailView(event: event)
                    } label: {
                        EventCardView(event: event)
                    }
                }
                .onDelete(perform: deleteItems)
            }
            .navigationTitle("Events")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: { showingSettings = true }) {
                        Image(systemName: "gear")
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
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
            .sheet(isPresented: $showingSettings) {
                SettingsView()
            }
        }
    }

    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                modelContext.delete(events[index])
            }
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
