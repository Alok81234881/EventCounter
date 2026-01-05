import SwiftUI
import SwiftData
import WidgetKit

struct PassedEventsView: View {
    @Query(sort: \Event.date, order: .reverse) private var events: [Event]
    @Environment(\.modelContext) private var modelContext
    @State private var sortOption: SortOption = .dateDesc

    enum SortOption: String, CaseIterable {
        case dateDesc = "Date (Recent First)"
        case week = "Last 7 Days"
        case month = "Last 30 Days"
        case alphabetical = "A-Z"
    }

    var body: some View {
        TimelineView(.periodic(from: .now, by: 1.0)) { timeline in
            let baseList = events.filter { $0.date <= timeline.date }
            
            let passed: [Event] = {
                switch sortOption {
                case .dateDesc:
                    return baseList.sorted { $0.date > $1.date }
                case .week:
                    let startOfWeek = Calendar.current.date(byAdding: .day, value: -7, to: timeline.date)!
                    return baseList
                        .filter { $0.date >= startOfWeek }
                        .sorted { $0.date > $1.date }
                case .month:
                    let startOfMonth = Calendar.current.date(byAdding: .day, value: -30, to: timeline.date)!
                    return baseList
                         .filter { $0.date >= startOfMonth }
                         .sorted { $0.date > $1.date }
                case .alphabetical:
                    return baseList.sorted { $0.title.localizedCaseInsensitiveCompare($1.title) == .orderedAscending }
                }
            }()
            
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
                        deleteItems(offsets: offsets, from: passed)
                    }
                }
            }
        }
        .navigationTitle("Passed")
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
