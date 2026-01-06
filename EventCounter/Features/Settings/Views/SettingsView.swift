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
    @State private var showPermissionAlert = false
    @State private var showingLogin = false
    
    var body: some View {
        ZStack {
            Color(uiColor: .systemBackground)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 24) {
                        
                        // 1. Profile Section
                        VStack(spacing: 8) {
                            ZStack(alignment: .bottomTrailing) {
                                // Avatar
                                Image(systemName: "person.crop.circle.fill") // Placeholder for illustration
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 80, height: 80)
                                    .foregroundStyle(Color(hex: "#E0C9A6") ?? .orange.opacity(0.3)) // Skin/Pastel tone
                                    .background(Circle().fill(Color(hex: "#F5E6D3") ?? .orange.opacity(0.1)))
                                
                                // Edit Badge
                                Circle()
                                    .fill(Color(hex: "#F59E0B") ?? .orange)
                                    .frame(width: 24, height: 24)
                                    .overlay(
                                        Image(systemName: "pencil")
                                            .font(.system(size: 12, weight: .bold))
                                            .foregroundStyle(.white)
                                    )
                                    .offset(x: 0, y: 0)
                            }
                            .padding(.top, 10)
                            
                            VStack(spacing: 4) {
                                Text(authService.isAuthenticated ? (authService.userId ?? "Alex Johnson") : "Guest User")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundStyle(Color.adaptivePrimaryText)
                                
                                Text(authService.isAuthenticated ? "alex.j@example.com" : "Sign in to sync")
                                    .font(.subheadline)
                                    .foregroundStyle(.gray)
                            }
                        }
                        .padding(.bottom, 10)
                        
                        // 2. Preferences Group
                        VStack(alignment: .leading, spacing: 20) {
                            Text("PREFERENCES")
                                .font(.caption)
                                .fontWeight(.bold)
                                .foregroundStyle(.gray)
                                .padding(.horizontal)
                            
                            VStack(spacing: 24) {
                                // iCloud Sync
                                SettingsRowItem(
                                    icon: "arrow.triangle.2.circlepath",
                                    iconColor: .purple,
                                    title: "iCloud Sync",
                                    subtitle: "Last synced: Just now"
                                ) {
                                    Toggle("", isOn: $iCloudSyncEnabled)
                                        .labelsHidden()
                                        .tint(.purple)
                                }
                                
                                // Theme Picker
                                SettingsRowItem(
                                    icon: "paintpalette.fill",
                                    iconColor: .purple,
                                    title: "Theme",
                                    subtitle: nil
                                ) {
                                    Picker("Theme", selection: $themeManager.currentTheme) {
                                        Text("Light").tag(AppTheme.light)
                                        Text("Dark").tag(AppTheme.dark)
                                        Text("System").tag(AppTheme.system)
                                    }
                                    .pickerStyle(.segmented)
                                    .frame(width: 180)
                                }
                                
                                // Notifications
                                SettingsRowItem(
                                    icon: "bell.fill",
                                    iconColor: .purple,
                                    title: "Notifications",
                                    subtitle: nil
                                ) {
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
                                    .labelsHidden()
                                    .tint(.purple)
                                }
                            }
                            .padding(.horizontal)
                        }
                        
                        Divider().padding(.horizontal)
                        
                        // 3. Support & Legal Group
                        VStack(alignment: .leading, spacing: 20) {
                            Text("SUPPORT & LEGAL")
                                .font(.caption)
                                .fontWeight(.bold)
                                .foregroundStyle(.gray)
                                .padding(.horizontal)
                            
                            VStack(spacing: 24) {
                                // Rate App
                                Button(action: { /* Rate */ }) {
                                    SettingsNavigationRow(icon: "star.fill", iconColor: .purple, title: "Rate the App")
                                }
                                
                                // FAQ
                                NavigationLink(destination: FAQView()) {
                                    SettingsNavigationRow(icon: "questionmark.circle.fill", iconColor: .purple, title: "FAQ & Support")
                                }
                                
                                // Privacy Policy
                                NavigationLink(destination: PrivacyPolicyView(isOnboarding: false)) {
                                    SettingsNavigationRow(icon: "lock.fill", iconColor: .purple, title: "Privacy Policy")
                                }
                                
                                // Terms
                                Button(action: { /* Terms */ }) {
                                    SettingsNavigationRow(icon: "doc.text.fill", iconColor: .purple, title: "Terms of Service")
                                }
                            }
                            .padding(.horizontal)
                        }
                        
                        // 4. Footer Actions
                        VStack(spacing: 16) {
                            if authService.isAuthenticated {
                                Button(action: { authService.signOut() }) {
                                    HStack {
                                        Image(systemName: "rectangle.portrait.and.arrow.right")
                                        Text("Log Out")
                                    }
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundStyle(Color.adaptivePrimaryText)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 56)
                                    .background(Color(hex: "#F5F5F5") ?? .gray.opacity(0.1))
                                    .clipShape(RoundedRectangle(cornerRadius: 16))
                                }
                                
                                Button(action: { /* Delete Account */ }) {
                                    Text("Delete Account")
                                        .font(.system(size: 14, weight: .medium))
                                        .foregroundStyle(.red)
                                }
                            } else {
                                Button(action: { showingLogin = true }) {
                                    HStack {
                                        Text("Sign In / Sign Up")
                                    }
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundStyle(.white)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 56)
                                    .background(Color.purple)
                                    .clipShape(RoundedRectangle(cornerRadius: 16))
                                }
                            }
                            
                            Text("Version 2.4.0 (124)")
                                .font(.caption)
                                .foregroundStyle(.gray.opacity(0.6))
                                .padding(.top, 10)
                        }
                        .padding(24)
                    }
                    .padding(.top, 10)
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: { dismiss() }) {
                    Image(systemName: "chevron.left")
                        .foregroundStyle(Color.adaptivePrimaryText)
                }
            }
            
            ToolbarItem(placement: .principal) {
                Text("Settings")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(Color.adaptivePrimaryText)
            }
        }
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
    
    // Logic for Notifications
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

// MARK: - Reusable Rows

struct SettingsRowItem<Content: View>: View {
    let icon: String
    let iconColor: Color
    let title: String
    let subtitle: String?
    let content: () -> Content
    
    init(icon: String, iconColor: Color, title: String, subtitle: String? = nil, @ViewBuilder content: @escaping () -> Content) {
        self.icon = icon
        self.iconColor = iconColor
        self.title = title
        self.subtitle = subtitle
        self.content = content
    }
    
    var body: some View {
        HStack(spacing: 16) {
            // Icon Circle
            ZStack {
                Circle()
                    .fill(iconColor.opacity(0.1))
                    .frame(width: 44, height: 44)
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundStyle(iconColor)
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(Color.adaptivePrimaryText)
                
                if let subtitle = subtitle {
                    Text(subtitle)
                        .font(.system(size: 12))
                        .foregroundStyle(.gray)
                }
            }
            
            Spacer()
            
            content()
        }
    }
}

struct SettingsNavigationRow: View {
    let icon: String
    let iconColor: Color
    let title: String
    
    var body: some View {
        HStack(spacing: 16) {
            // Icon Circle
            ZStack {
                Circle()
                    .fill(iconColor.opacity(0.1))
                    .frame(width: 44, height: 44)
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundStyle(iconColor)
            }
            
            Text(title)
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(Color.adaptivePrimaryText)
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(Color.gray.opacity(0.4))
        }
    }
}

#Preview {
    SettingsView()
        .environmentObject(ThemeManager.shared)
}
