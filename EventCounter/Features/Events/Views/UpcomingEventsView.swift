import SwiftUI
import SwiftData
import WidgetKit

struct UpcomingEventsView: View {
    @Query(sort: \Event.createdAt, order: .reverse) private var events: [Event]
    @Environment(\.modelContext) private var modelContext
    @State private var showingAddEvent = false
    @State private var sortOption: SortOption = .dateAsc

    enum SortOption: String, CaseIterable {
        case dateAsc = "Date (Soonest First)"
        case week = "Next 7 Days"
        case month = "Next 30 Days"
        case alphabetical = "A-Z"
    }

    private var upcomingEvents: [Event] {
         let now = Date()
         // Base filter: always future events
         let baseList = events.filter { $0.date > now }
         
         switch sortOption {
         case .dateAsc:
             return baseList.sorted { $0.date < $1.date }
         case .week:
             let endOfWeek = Calendar.current.date(byAdding: .day, value: 7, to: now)!
             return baseList
                .filter { $0.date <= endOfWeek }
                .sorted { $0.date < $1.date }
         case .month:
             let endOfMonth = Calendar.current.date(byAdding: .day, value: 30, to: now)!
             return baseList
                .filter { $0.date <= endOfMonth }
                .sorted { $0.date < $1.date }
         case .alphabetical:
             return baseList.sorted { $0.title.localizedCaseInsensitiveCompare($1.title) == .orderedAscending }
         }
    }

    var body: some View {
        TimelineView(.periodic(from: .now, by: 1.0)) { timeline in
            // Use the computed property which handles logic, but ensure 'now' in logic stays fresh.
            // Since computed property uses Date(), view refresh triggers re-calc.
            let upcoming = upcomingEvents
            
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
                            NavigationLink(value: event.id) {
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
            ToolbarItem(placement: .topBarLeading) {
                Menu {
                    Picker("Filter & Sort", selection: $sortOption) {
                        ForEach(SortOption.allCases, id: \.self) { option in
                            Text(option.rawValue).tag(option)
                        }
                    }
                } label: {
                    Label("Filter", systemImage: "line.3.horizontal.decrease.circle")
                }
            }
            
            ToolbarItem(placement: .primaryAction) {
                Button(action: { showingAddEvent = true }) {
                    Label("Add Item", systemImage: "plus")
                }
            }
        }
        .sheet(isPresented: $showingAddEvent) {
            AddEventView()
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
