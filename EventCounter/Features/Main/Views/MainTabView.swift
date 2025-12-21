import SwiftUI
import SwiftData
import Foundation

struct MainTabView: View {
    @State private var selectedTab: Int = 0
    @State private var upcomingPath = NavigationPath()
    @State private var passedPath = NavigationPath()
    
    @Environment(\.modelContext) private var modelContext
    
    var body: some View {
        TabView(selection: $selectedTab) {
            NavigationStack(path: $upcomingPath) {
                UpcomingEventsView()
                    .navigationDestination(for: UUID.self) { eventID in
                        EventResolverView(eventID: eventID)
                    }
            }
            .tabItem {
                Label("Upcoming", systemImage: "calendar")
            }
            .tag(0)
            
            NavigationStack(path: $passedPath) {
                PassedEventsView()
                    .navigationDestination(for: UUID.self) { eventID in
                        EventResolverView(eventID: eventID)
                    }
            }
            .tabItem {
                Label("Passed", systemImage: "clock.arrow.circlepath")
            }
            .tag(1)
            
            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
                .tag(2)
            
            ProfileView()
                .tabItem {
                    Label("Profile", systemImage: "person.circle")
                }
                .tag(3)
        }
        .onOpenURL { url in
            handleDeepLink(url)
        }
    }
    
    private func handleDeepLink(_ url: URL) {
        guard url.scheme == "eventcounter", url.host == "event" else { return }
        
        // Extract ID from path (removing leading slash)
        let eventIDString = url.path.replacingOccurrences(of: "/", with: "")
        guard let uuid = UUID(uuidString: eventIDString) else { return }
        
        fetchAndShowEvent(eventID: uuid)
    }
    
    private func fetchAndShowEvent(eventID: UUID) {
        let descriptor = FetchDescriptor<Event>(
            predicate: #Predicate<Event> { event in
                event.id == eventID
            }
        )
        
        do {
            let results = try modelContext.fetch(descriptor)
            if let event = results.first {
                if event.date > Date() {
                    selectedTab = 0
                    upcomingPath.append(event.id)
                } else {
                    selectedTab = 1
                    passedPath.append(event.id)
                }
            }
        } catch {
            print("Failed to fetch event for deep link: \(error)")
        }
    }
}

#Preview {
    MainTabView()
}
