import SwiftUI

struct MainTabView: View {
    @State private var selectedTab: Int = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            UpcomingEventsView()
                .tabItem {
                    Label("Upcoming", systemImage: "calendar")
                }
                .tag(0)
            
            PassedEventsView()
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
    }
}

#Preview {
    MainTabView()
}
