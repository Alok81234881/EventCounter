import SwiftUI
import WidgetKit
import UserNotifications

struct SettingsView: View {
    @ObservedObject var authService = AuthenticationService.shared
    @ObservedObject var notificationService = NotificationService.shared
    @EnvironmentObject var themeManager: ThemeManager
    @AppStorage("notificationsEnabled") private var notificationsEnabled = true
    @AppStorage("iCloudSyncEnabled") private var iCloudSyncEnabled = true
    
    @Environment(\.dismiss) private var dismiss
    @State private var showingLogin = false
    @State private var showPermissionAlert = false
    
    private var appTheme: AppTheme {
        themeManager.currentTheme
    }
    
    var body: some View {
        ZStack {
            Color.adaptiveGroupedBackground
                .ignoresSafeArea()
            
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Header
                    HStack {
                        Button {
                            dismiss()
                        } label: {
                            Image(systemName: "chevron.backward")
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundStyle(Color.adaptivePrimaryText)
                                .frame(width: 50, height: 50)
                                .background(Color.adaptiveSecondaryBackground)
                                .clipShape(Circle())
                                .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
                        }
                        Spacer()
                    }
                    .padding(.top, 20)
                    
                    Text("Settings")
                        .font(.system(size: 42, weight: .bold))
                        .foregroundStyle(Color.adaptivePrimaryText)
                    
                    // ACCOUNT Section
                    VStack(alignment: .leading, spacing: 16) {
                        SectionHeader(title: "ACCOUNT", icon: "👤", color: Color(hex: "#E0EFFF") ?? .blue.opacity(0.1), textColor: Color(hex: "#4A90E2") ?? .blue)
                        
                        VStack(spacing: 0) {
                            if authService.isAuthenticated {
                                Button {
                                    // Profile action
                                } label: {
                                    HStack(spacing: 16) {
                                        ZStack {
                                            Circle()
                                                .fill(LinearGradient(colors: [.orange.opacity(0.3), .purple.opacity(0.3)], startPoint: .topLeading, endPoint: .bottomTrailing))
                                                .frame(width: 50, height: 50)
                                            Image(systemName: "person.fill")
                                                .font(.system(size: 24))
                                                .foregroundStyle(Color.adaptivePrimaryText.opacity(0.6))
                                        }
                                        
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text(authService.userId ?? "Alex Doe")
                                                .font(.system(size: 18, weight: .bold))
                                                .foregroundStyle(Color.adaptivePrimaryText)
                                            Text("alex.doe@example.com")
                                                .font(.system(size: 14))
                                                .foregroundStyle(Color.adaptiveSecondaryText)
                                        }
                                        
                                        Spacer()
                                        
                                        Image(systemName: "chevron.right")
                                            .font(.system(size: 14, weight: .semibold))
                                            .foregroundStyle(.gray.opacity(0.5))
                                    }
                                    .padding(20)
                                }
                            } else {
                                Button {
                                    showingLogin = true
                                } label: {
                                    HStack(spacing: 16) {
                                        Image(systemName: "person.crop.circle.badge.plus")
                                            .font(.system(size: 24))
                                            .foregroundStyle(.blue)
                                        Text("Sign In with Apple")
                                            .font(.system(size: 18, weight: .bold))
                                            .foregroundStyle(Color.adaptivePrimaryText)
                                        Spacer()
                                    }
                                    .padding(20)
                                }
                            }
                            
                            Divider()
                                .padding(.horizontal, 20)
                            
                            HStack(spacing: 16) {
                                ZStack {
                                    Circle()
                                        .fill(Color.blue.opacity(0.1))
                                        .frame(width: 40, height: 40)
                                    Image(systemName: "cloud.fill")
                                        .font(.system(size: 18))
                                        .foregroundStyle(.blue)
                                }
                                
                                Text("iCloud Sync")
                                    .font(.system(size: 18, weight: .bold))
                                    .foregroundStyle(Color.adaptivePrimaryText)
                                
                                Spacer()
                                
                                Toggle("", isOn: $iCloudSyncEnabled)
                                    .tint(.blue)
                            }
                            .padding(20)
                        }
                        .background(Color.adaptiveSecondaryBackground)
                        .cornerRadius(24)
                        .shadow(color: .black.opacity(0.03), radius: 10, x: 0, y: 5)
                        
                        Text("Last synced: Just now")
                            .font(.system(size: 12))
                            .foregroundStyle(Color.adaptiveSecondaryText)
                            .padding(.leading, 8)
                    }
                    
                    // APPEARANCE Section
                    VStack(alignment: .leading, spacing: 16) {
                        SectionHeader(title: "APPEARANCE", icon: "🎨", color: Color(hex: "#F5EBFF") ?? .purple.opacity(0.1), textColor: Color(hex: "#A855F7") ?? .purple)
                        
                        VStack(spacing: 0) {
                            ForEach(AppTheme.allCases) { theme in
                                Button {
                                    themeManager.currentTheme = theme
                                } label: {
                                    HStack(spacing: 16) {
                                        ZStack {
                                            Circle()
                                                .fill(Color.purple.opacity(0.1))
                                                .frame(width: 40, height: 40)
                                            Image(systemName: theme == .system ? "circle.lefthalf.filled" : (theme == .dark ? "moon.fill" : "sun.max.fill"))
                                                .font(.system(size: 18))
                                                .foregroundStyle(.purple)
                                        }
                                        
                                        VStack(alignment: .leading, spacing: 2) {
                                            Text(theme.rawValue)
                                                .font(.system(size: 18, weight: .bold))
                                                .foregroundStyle(Color.adaptivePrimaryText)
                                            Text(theme == .system ? "Follow system setting" : (theme == .dark ? "Easier on the eyes" : "Always light"))
                                                .font(.system(size: 13))
                                                .foregroundStyle(Color.adaptiveSecondaryText)
                                        }
                                        
                                        Spacer()
                                        
                                        if appTheme == theme {
                                            Image(systemName: "checkmark.circle.fill")
                                                .font(.system(size: 20))
                                                .foregroundStyle(.purple)
                                        }
                                    }
                                    .padding(20)
                                }
                                
                                if theme != AppTheme.allCases.last {
                                    Divider()
                                        .padding(.horizontal, 20)
                                }
                            }
                        }
                        .background(Color.adaptiveSecondaryBackground)
                        .cornerRadius(24)
                        .shadow(color: .black.opacity(0.03), radius: 10, x: 0, y: 5)
                    }
                    
                    // NOTIFICATIONS Section
                    VStack(alignment: .leading, spacing: 16) {
                        SectionHeader(title: "NOTIFICATIONS", icon: "🔔", color: Color(hex: "#FFF4E5") ?? .orange.opacity(0.1), textColor: Color(hex: "#F59E0B") ?? .orange)
                        
                        VStack(spacing: 0) {
                            HStack(spacing: 16) {
                                ZStack {
                                    Circle()
                                        .fill(Color.orange.opacity(0.1))
                                        .frame(width: 40, height: 40)
                                    Image(systemName: "bell.fill")
                                        .font(.system(size: 18))
                                        .foregroundStyle(.orange)
                                }
                                
                                Text("Allow Notifications")
                                    .font(.system(size: 18, weight: .bold))
                                    .foregroundStyle(Color.adaptivePrimaryText)
                                
                                Spacer()
                                
                                Toggle("", isOn: Binding(
                                    get: { notificationsEnabled && notificationService.isAuthorized },
                                    set: { newValue in
                                        if newValue {
                                            enableNotifications()
                                        } else {
                                            notificationsEnabled = false
                                        }
                                    }
                                ))
                                .tint(.orange)
                            }
                            .padding(20)
                            
                            Divider()
                                .padding(.horizontal, 20)
                            HStack(spacing: 16) {
                                NavigationLink(destination: FAQView()) {
                                    ZStack {
                                                                           Circle()
                                                                               .fill(Color.purple.opacity(0.1))
                                                                               .frame(width: 40, height: 40)
                                                                           Image(systemName: "questionmark.message")
                                                                               .font(.system(size: 18))
                                                                               .foregroundStyle(.purple)
                                                                       }
                                    
                                    Text("FAQs")
                                        .font(.system(size: 18, weight: .bold))
                                        .foregroundStyle(Color.adaptivePrimaryText)
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .font(.system(size: 14, weight: .semibold))
                                        .foregroundStyle(.gray.opacity(0.5))
                                }
                            }
                            .padding(20)
                            
                           // Button {
                                // Default reminder action
//                            } label: {
//                                HStack(spacing: 16) {
//                                    ZStack {
//                                        Circle()
//                                            .fill(Color.gray.opacity(0.1))
//                                            .frame(width: 40, height: 40)
//                                        Image(systemName: "timer")
//                                            .font(.system(size: 18))
//                                            .foregroundStyle(.gray)
//                                    }
//                                    
//                                    Text("Default Reminder")
//                                        .font(.system(size: 18, weight: .bold))
//                                        .foregroundStyle(Color.adaptivePrimaryText)
//                                    
//                                    Spacer()
//                                    
//                                    Text("2 hours before")
//                                        .font(.system(size: 14, weight: .semibold))
//                                        .foregroundStyle(.orange)
//                                    
//                                    Image(systemName: "chevron.right")
//                                        .font(.system(size: 14, weight: .semibold))
//                                        .foregroundStyle(.gray.opacity(0.5))
//                                }
//
//                            }
                        }
                        .background(Color.adaptiveSecondaryBackground)
                        .cornerRadius(24)
                        .shadow(color: .black.opacity(0.03), radius: 10, x: 0, y: 5)
                    }
                    
                    // Footer
                    VStack(spacing: 16) {
                        VStack(spacing: 4) {
                            Text("VERSION 3.0.1")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundStyle(.gray.opacity(0.7))
                                .tracking(1)
                            Text("Made with ❤️ for iOS")
                                .font(.system(size: 12))
                                .foregroundStyle(.gray.opacity(0.5))
                        }
                        
                        HStack(spacing: 24) {
                            Button("Privacy Policy") {}
                            Button("Terms of Service") {}
                        }
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(.gray.opacity(0.7))
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 40)
                }
                .padding(.horizontal, 24)
            }
        }
        .navigationBarHidden(true)
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

struct SectionHeader: View {
    let title: String
    let icon: String
    let color: Color
    let textColor: Color
    
    var body: some View {
        HStack(spacing: 8) {
            HStack(spacing: 6) {
                Text(title)
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(textColor)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(color)
            .cornerRadius(12)
            
            Text(icon)
                .font(.system(size: 20))
        }
    }
}

#Preview {
    SettingsView()
        .environmentObject(ThemeManager.shared)
}
