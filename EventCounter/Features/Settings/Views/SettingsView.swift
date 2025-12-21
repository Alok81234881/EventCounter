import SwiftUI
import WidgetKit
import UserNotifications

// Theme Enum
enum AppTheme: String, CaseIterable, Identifiable {
    case system = "System"
    case light = "Light"
    case dark = "Dark"
    
    var id: String { self.rawValue }
}

struct SettingsView: View {
    @ObservedObject var authService = AuthenticationService.shared
    @ObservedObject var notificationService = NotificationService.shared
    @AppStorage("appTheme") private var appTheme: AppTheme = .system
    @AppStorage("notificationsEnabled") private var notificationsEnabled = true
    
    @State private var showingLogin = false
    @State private var showPermissionAlert = false
    
    var body: some View {
        List {
            Section("Appearance") {
                Picker("Theme", selection: $appTheme) {
                    ForEach(AppTheme.allCases) { theme in
                        Text(theme.rawValue).tag(theme)
                    }
                }
                .pickerStyle(.segmented)
            }
            
            Section("Notifications") {
                Toggle("Enable Notifications", isOn: Binding(
                    get: { notificationsEnabled && notificationService.isAuthorized },
                    set: { newValue in
                        if newValue {
                            // User wants to enable
                            enableNotifications()
                        } else {
                            // User wants to disable
                            notificationsEnabled = false
                        }
                    }
                ))
            }
            
            Section("Profile") {
                if authService.isAuthenticated {
                    HStack {
                       Image(systemName: "person.circle.fill")
                            .font(.largeTitle)
                            .foregroundStyle(.blue)
                        
                        VStack(alignment: .leading) {
                            Text("Signed In")
                                .font(.headline)
                            Text(authService.userId ?? "User")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                                .lineLimit(1)
                                .truncationMode(.middle)
                        }
                    }
                    
                    Button("Sign Out", role: .destructive) {
                        authService.signOut()
                    }
                } else {
                    Button {
                        showingLogin = true
                    } label: {
                        Label("Sign In with Apple", systemImage: "applelogo")
                            .foregroundStyle(.primary)
                    }
                }
            }
            
            Section("About") {
                HStack {
                    Text("Version")
                    Spacer()
                    Text("1.0.0")
                        .foregroundStyle(.secondary)
                }
            }
        }
        .navigationTitle("Settings")
        .sheet(isPresented: $showingLogin) {
            LoginView()
        }
        .onAppear {
            notificationService.checkPermissionStatus()
        }
        .alert("Permission Required", isPresented: $showPermissionAlert) {
            Button("Settings") {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("Notifications have been disabled for this app. Please enable them in Settings.")
        }
    }
    
    private func enableNotifications() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                switch settings.authorizationStatus {
                case .notDetermined:
                    notificationService.requestPermissions()
                    // Optimistically set to true, listener will correct if denied
                    notificationsEnabled = true
                case .denied:
                    showPermissionAlert = true
                case .authorized, .provisional, .ephemeral:
                    notificationsEnabled = true
                    notificationService.isAuthorized = true
                @unknown default:
                    break
                }
            }
        }
    }
}

#Preview {
    SettingsView()
}
