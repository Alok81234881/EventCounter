//
//  EventCounterApp.swift
//  EventCounter
//
//  Created by Alok SIngh on 14/12/25.
//

import SwiftUI
import SwiftData

@main
struct EventCounterApp: App {
    init() {
        NotificationService.shared.requestPermissions()
    }
    
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Event.self,
        ])
        
        // IMPORTANT: Replace 'group.com.yourcompany.eventcount' with your actual App Group ID from Xcode
        let modelConfiguration: ModelConfiguration
        if let appGroupURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.com.alok.singh.EventCounter") {
             let storeURL = appGroupURL.appendingPathComponent("EventCout.sqlite")
             modelConfiguration = ModelConfiguration(schema: schema, url: storeURL)
        } else {
            print("WARNING: App Group not found. Using default storage (not shared with widget).")
            modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        }

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    @AppStorage("appTheme") private var appTheme: AppTheme = .system

    var body: some Scene {
        WindowGroup {
            MainTabView()
                .preferredColorScheme(appTheme == .system ? nil : (appTheme == .dark ? .dark : .light))
        }
        .modelContainer(sharedModelContainer)
    }
}
