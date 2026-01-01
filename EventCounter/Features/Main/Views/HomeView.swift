import SwiftUI
import WidgetKit
import EventKit
import SwiftData

struct HomeView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Event.createdAt, order: .reverse) private var events: [Event]
    
    @State private var selectedCategory: EventCategory? // nil = All
    @State private var searchText = ""
    @State private var showingAddEvent = false
    @State private var showingCalendarImport = false
    @State private var homePath = NavigationPath()
    
    // Sorting States
    @State private var upcomingSort: SortOption = .nearest
    @State private var pastSort: SortOption = .nearest
    
    enum SortOption: String, CaseIterable {
        case nearest = "Nearest"
        case recentlyAdded = "Recently Added"
        case alphabetically = "Alphabetically"
    }
    
    // Filtered Events
    var upcomingEvents: [Event] {
        let upcoming = events.filter { $0.date > .now }
        let categoryFiltered = selectedCategory == nil ? upcoming : upcoming.filter { $0.category == selectedCategory }
        
        let searched: [Event]
        if searchText.isEmpty {
            searched = categoryFiltered
        } else {
            searched = categoryFiltered.filter { $0.title.localizedCaseInsensitiveContains(searchText) }
        }
        
        return sortEvents(searched, by: upcomingSort, isPast: false)
    }
    
    var pastEvents: [Event] {
        // Filter past events
        let passed = events.filter { $0.date <= .now }
        let categoryFiltered = selectedCategory == nil ? passed : passed.filter { $0.category == selectedCategory }
        
        let searched: [Event]
        if searchText.isEmpty {
            searched = categoryFiltered
        } else {
            searched = categoryFiltered.filter { $0.title.localizedCaseInsensitiveContains(searchText) }
        }
        
        return sortEvents(searched, by: pastSort, isPast: true)
    }
    
    private func sortEvents(_ events: [Event], by option: SortOption, isPast: Bool) -> [Event] {
        switch option {
        case .nearest:
            return events.sorted { isPast ? $0.date > $1.date : $0.date < $1.date }
        case .recentlyAdded:
            return events.sorted { $0.createdAt > $1.createdAt }
        case .alphabetically:
            return events.sorted { $0.title.localizedCaseInsensitiveCompare($1.title) == .orderedAscending }
        }
    }
    
    var body: some View {
        NavigationStack(path: $homePath) {
            ZStack(alignment: .bottomTrailing) {
                // Main Content
                ScrollView {
                    VStack(spacing: 24) {
                        // 1. Header Area
                        VStack(spacing: 20) {
                            // Row 1: Top Bar (Notification & Settings)
                            HStack {
                                Button(action: { showingCalendarImport = true }) {
                                    Image(systemName: "calendar.badge.plus")
                                        .font(.system(size: 20))
                                        .foregroundStyle(Color.adaptivePrimaryText)
                                        .frame(width: 44, height: 44)
                                        .background(Color.adaptiveSecondaryBackground)
                                        .clipShape(Circle())
                                        .shadow(color: .black.opacity(0.05), radius: 5)
                                }
                                
                                Spacer()
                                
                                NavigationLink(destination: SettingsView()) {
                                    Image(systemName: "gearshape.fill")
                                        .font(.system(size: 20))
                                        .foregroundStyle(Color.adaptivePrimaryText)
                                        .frame(width: 44, height: 44)
                                        .background(Color.adaptiveSecondaryBackground)
                                        .clipShape(Circle())
                                        .shadow(color: .black.opacity(0.05), radius: 5)
                                }
                            }
                            .padding(.horizontal)
                            
                            // Row 2: Title
                            HStack {
                                Text("My Events")
                                    .font(.system(size: 34, weight: .bold))
                                    .foregroundStyle(Color.adaptivePrimaryText)
                                Spacer()
                            }
                            .padding(.horizontal)
                            
                            // Row 3: Search Bar
                            HStack {
                                Image(systemName: "magnifyingglass")
                                    .foregroundStyle(.gray)
                                    .font(.system(size: 18))
                                
                                TextField("", text: $searchText, prompt: Text("Search events...").foregroundColor(.adaptiveSecondaryText))
                                    .foregroundStyle(Color.adaptivePrimaryText)
                                    .tint(.orange)
                                    .submitLabel(.done)
                                    .onSubmit {
                                        hideKeyboard()
                                    }
                                
                                if !searchText.isEmpty {
                                    Button(action: {
                                        searchText = ""
                                    }) {
                                        Image(systemName: "xmark.circle.fill")
                                            .foregroundStyle(Color.adaptiveSecondaryText)
                                            .font(.system(size: 18))
                                    }
                                    .padding(.trailing, 4)
                                }
                            }
                            .padding()
                            .background(Color.adaptiveSecondaryBackground)
                            .clipShape(RoundedRectangle(cornerRadius: 24))
                            .shadow(color: .black.opacity(0.03), radius: 10, x: 0, y: 4)
                            .padding(.horizontal)

                            // Row 4: Categories
                            categoryFilterView
                        }
                        .padding(.top, 10)
                        
                        // 2. Upcoming Section
                        if !upcomingEvents.isEmpty {
                            VStack(alignment: .leading, spacing: 16) {
                                sectionHeader(title: "UPCOMING", icon: "🚀", color: .orange, sortOption: $upcomingSort)
                                ForEach(upcomingEvents) { event in
                                    NavigationLink(value: event.id) {
                                        HomeEventCardView(event: event)
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                            .padding(.horizontal)
                        } else if pastEvents.isEmpty {
                           // Empty State if absolutely nothing
                            ContentUnavailableView(
                                "No Events",
                                systemImage: "calendar.badge.plus",
                                description: Text("Tap + to create your first event!")
                                    .foregroundStyle(Color.adaptiveSecondaryText)
                            )
                            .foregroundStyle(Color.adaptivePrimaryText)
                            .padding(.top, 40)
                        }
                        
                        // 3. Memory Lane Section (Past)
                        if !pastEvents.isEmpty {
                            VStack(alignment: .leading, spacing: 16) {
                                sectionHeader(title: "MEMORY LANE", icon: "🕰️", color: .gray, sortOption: $pastSort)
                                ForEach(pastEvents) { event in
                                    NavigationLink(value: event.id) {
                                        HomeEventCardView(event: event)
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                            .padding(.horizontal)
                        }
                        
                        // Bottom Padding for FAB
                        Color.clear.frame(height: 80)
                    }
                }
                .navigationDestination(for: UUID.self) { eventID in
                    EventResolverView(eventID: eventID)
                }
                .background(Color.adaptiveGroupedBackground)
                
                // FAB
                Button(action: { showingAddEvent = true }) {
                    ZStack {
                        Circle()
                            .fill(Color.orange)
                            .shadow(color: .orange.opacity(0.4), radius: 10, x: 0, y: 5)
                            
                        Image(systemName: "plus")
                            .font(.system(size: 30, weight: .light))
                            .foregroundStyle(.white)
                    }
                    .frame(width: 64, height: 64)
                    .padding()
                }
            }
            .onTapGesture {
                hideKeyboard()
            }
            .sheet(isPresented: $showingAddEvent) {
                AddEventView()
            }
            .sheet(isPresented: $showingCalendarImport) {
                BatchCalendarImportView { selectedEvents in
                    batchImportEvents(selectedEvents)
                }
            }
        }
        .onOpenURL { url in
            handleDeepLink(url)
        }
        .onAppear {
            // Debug: List pending notifications
            NotificationService.shared.listPendingNotifications()
        }
    }
    
    private func handleDeepLink(_ url: URL) {
        // Deep link format: eventcounter://event/{id}
        guard url.scheme == "eventcounter" else { return }
        
        let pathComponents = url.pathComponents
        if url.host == "event" || pathComponents.contains("event") {
            let idString = url.lastPathComponent
            if let id = UUID(uuidString: idString) {
                // Navigate to the event
                homePath = NavigationPath() // Clear path to ensure we start from Home
                homePath.append(id)
            }
        }
    }
    
    private func batchImportEvents(_ ekEvents: [EKEvent]) {
        for ekEvent in ekEvents {
            let newEvent = Event(
                title: ekEvent.title,
                date: ekEvent.startDate,
                note: ekEvent.notes,
                category: .personal,
                colorHex: "#F5A623", // Default orange
                notifyBefore: 15,    // Default 15 min
                location: ekEvent.location
            )
            modelContext.insert(newEvent)
            NotificationService.shared.scheduleNotification(for: newEvent)
        }
        
        try? modelContext.save()
        WidgetCenter.shared.reloadAllTimelines()
    }
    
    // MARK: - Subviews
    
    private var headerView: some View {
        HStack {
            Text("My Events")
                .font(.system(size: 34, weight: .bold))
                .foregroundStyle(.black)
            
            Spacer()
            
            // Search Button (Visual Only for now)
            Button(action: {}) {
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 20))
                    .foregroundStyle(Color.adaptivePrimaryText)
                    .frame(width: 44, height: 44)
                    .background(Color.adaptiveSecondaryBackground)
                    .clipShape(Circle())
                    .shadow(color: .black.opacity(0.05), radius: 5)
            }
            
            // Settings Button (Since we removed the tab bar, we need access to Settings)
            NavigationLink(destination: SettingsView()) {
                Image(systemName: "gearshape.fill")
                    .font(.system(size: 20))
                    .foregroundStyle(Color.adaptivePrimaryText)
                    .frame(width: 44, height: 44)
                    .background(Color.adaptiveSecondaryBackground)
                    .clipShape(Circle())
                    .shadow(color: .black.opacity(0.05), radius: 5)
            }
        }
        .padding(.horizontal)
    }
    
    private var categoryFilterView: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                // "All" Pill
                CategoryPill(
                    title: "All",
                    icon: "square.grid.2x2.fill",
                    isSelected: selectedCategory == nil,
                    color: .orange
                ) {
                    withAnimation { selectedCategory = nil }
                }
                
                // Dynamic Categories
                ForEach(EventCategory.allCases, id: \.self) { category in
                    CategoryPill(
                        title: category.displayName,
                        icon: category.icon,
                        isSelected: selectedCategory == category,
                        color: Color(red: 1.0, green: 0.7, blue: 0.2) // Golden Yellow from Login
                    ) {
                        withAnimation { selectedCategory = category }
                    }
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
        }
    }
    
    private func sectionHeader(title: String, icon: String, color: Color, sortOption: Binding<SortOption>) -> some View {
        HStack {
            HStack(spacing: 8) {
                Text(title)
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(color)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(color.opacity(0.1))
                    .clipShape(Capsule())
                
                Text(icon)
                    .font(.caption)
            }
            
            Spacer()
            
            Menu {
                ForEach(SortOption.allCases, id: \.self) { option in
                    Button {
                        sortOption.wrappedValue = option
                    } label: {
                        HStack {
                            Text(option.rawValue)
                            if sortOption.wrappedValue == option {
                                Image(systemName: "checkmark")
                            }
                        }
                    }
                }
            } label: {
                HStack(spacing: 4) {
                    Text(sortOption.wrappedValue.rawValue)
                        .font(.system(size: 12, weight: .medium))
                        .lineLimit(1)
                    Image(systemName: "chevron.down")
                        .font(.system(size: 10, weight: .bold))
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .frame(width: 150)
                .background(Color.adaptiveSecondaryBackground)
                .foregroundStyle(Color.adaptiveSecondaryText)
                .clipShape(Capsule())
                .shadow(color: .black.opacity(0.05), radius: 5)
            }
        }
    }
}

// MARK: - Category Pill Component
struct CategoryPill: View {
    let title: String
    let icon: String
    let isSelected: Bool
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 14))
                Text(title)
                    .font(.system(size: 14, weight: .medium))
            }
            .foregroundStyle(isSelected ? .white : .adaptivePrimaryText.opacity(0.8))
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(
                Capsule()
                    .fill(isSelected ? color : Color.adaptiveSecondaryBackground)
                    .shadow(color: .black.opacity(0.05), radius: 5)
            )
        }
    }
}

#Preview {
    HomeView()
        .modelContainer(for: Event.self, inMemory: true)
}

// MARK: - Keyboard Helper
extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
