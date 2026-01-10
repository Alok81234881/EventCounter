import SwiftUI
import WidgetKit
import UserNotifications

struct SettingsView: View {
    @ObservedObject var authService = AuthenticationService.shared
    @ObservedObject var notificationService = NotificationService.shared
    @ObservedObject var cloudService = CloudKitService.shared
    @EnvironmentObject var themeManager: ThemeManager
    @AppStorage("notificationsEnabled") private var notificationsEnabled = true
    @AppStorage("iCloudSyncEnabled") private var iCloudSyncEnabled = true
    
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) var context
    @Environment(\.colorScheme) var colorScheme
    @State private var showPermissionAlert = false
    @State private var showingLogin = false
    @State private var showDeleteAlert = false
    @State private var showLogoutAlert = false
    
    var body: some View {
        ZStack {
            // Main Content
            ZStack {
                Color(uiColor: .systemBackground)
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 24) {
                            
                            // 1. Profile Section
//                            VStack(spacing: 8) {
//                                ZStack(alignment: .bottomTrailing) {
//                                    // Avatar
//                                    Image(systemName: "person.crop.circle.fill")
//                                        .resizable()
//                                        .aspectRatio(contentMode: .fit)
//                                        .frame(width: 80, height: 80)
//                                        .foregroundStyle(Color(hex: "#E0C9A6") ?? .orange.opacity(0.3))
//                                        .background(Circle().fill(Color(hex: "#F5E6D3") ?? .orange.opacity(0.1)))
//                                    
//                                    // Edit Badge
//                                    Circle()
//                                        .fill(Color(hex: "#F59E0B") ?? .orange)
//                                        .frame(width: 24, height: 24)
//                                        .overlay(
//                                            Image(systemName: "pencil")
//                                                .font(.system(size: 12, weight: .bold))
//                                                .foregroundStyle(.white)
//                                        )
//                                        .offset(x: 0, y: 0)
//                                }
//                                .padding(.top, 10)
//                                
//                                VStack(spacing: 4) {
//                                    Text(authService.userName ?? "Guest User")
//                                        .font(.title2)
//                                        .fontWeight(.bold)
//                                        .foregroundStyle(Color.adaptivePrimaryText)
//                                    
//                                    Text(authService.userEmail ?? "No email linked")
//                                        .font(.subheadline)
//                                        .foregroundStyle(.gray)
//                                }
//                            }
 //                           .padding(.bottom, 10)
                            
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
                                        subtitle: cloudService.isSyncing ? "Syncing..." : formatSyncDate(cloudService.lastSyncDate)
                                    ) {
                                        HStack {
                                            if cloudService.isSyncing {
                                                ProgressView()
                                                    .padding(.trailing, 8)
                                            }
                                            Toggle("", isOn: Binding(
                                                get: { iCloudSyncEnabled },
                                                set: { newValue in
                                                    iCloudSyncEnabled = newValue
                                                    if newValue {
                                                        // Trigger full sync
                                                        Task {
                                                            await cloudService.performFullSync(context: context)
                                                        }
                                                    }
                                                }
                                            ))
                                            .labelsHidden()
                                            .tint(.purple)
                                        }
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
                                    Button(action: { rateApp() }) {
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
                                    NavigationLink(destination: TermsOfServiceView()) {
                                        SettingsNavigationRow(icon: "doc.text.fill", iconColor: .purple, title: "Terms of Service")
                                    }
                                }
                                .padding(.horizontal)
                            }
                            
                            // 4. Footer Actions
                            if authService.isAuthenticated {
                                VStack(spacing: 16) {
                                    // Log Out
                                    Button {
                                        showLogoutAlert = true
                                    } label: {
                                        HStack {
                                            Image(systemName: "rectangle.portrait.and.arrow.right")
                                            Text("Log Out")
                                        }
                                        .font(.system(size: 17, weight: .semibold))
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 16)
                                        .foregroundStyle(Color.adaptivePrimaryText)
                                        .background(
                                            RoundedRectangle(cornerRadius: 28)
                                                .fill(Color.purple.opacity(0.5))
                                        )
                                    }
                                    
                                    // Delete Account
                                    Button {
                                        showDeleteAlert = true
                                    } label: {
                                        Text("Delete Account")
                                            .font(.system(size: 17, weight: .semibold))
                                            .foregroundColor(.red)
                                            .frame(maxWidth: .infinity)
                                            .padding(.vertical, 16)
                                            .background(Color.red.opacity(0.08))
                                            .cornerRadius(28)
                                    }
                                    
                                    Text("Permanently delete your account and all data. This action cannot be undone.")
                                        .font(.system(size: 13))
                                        .foregroundColor(.secondary)
                                        .multilineTextAlignment(.center)
                                        .padding(.horizontal)
                                    
                                    Text("Version 2.4.0 (124)")
                                        .font(.caption)
                                        .foregroundStyle(.gray.opacity(0.6))
                                        .padding(.top, 4)
                                }
                                .padding(24)
                            }
                        }
                        .padding(.top, 10)
                    }
                }
            }
            .blur(radius: showDeleteAlert ? 2 : 0)
            
            // Delete Account Modal Overlay
            if showDeleteAlert {
                DeleteAccountModal(
                    onDelete: {
                        showDeleteAlert = false
                        authService.deleteAccount(context: context)
                    },
                    onCancel: {
                        showDeleteAlert = false
                    }
                )
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
        .alert("Log Out?", isPresented: $showLogoutAlert) {
            Button("Cancel", role: .cancel) {}
            Button("Log Out", role: .destructive) {
                authService.signOut(context: context)
            }
        } message: {
            Text("Are you sure you want to log out? You will need to sign in again to access your events.")
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
    private func formatSyncDate(_ date: Date?) -> String {
        guard let date = date else { return "Not synced yet" }
        
        let calendar = Calendar.current
        if calendar.isDateInToday(date) {
            return "Today, \(date.formatted(date: .omitted, time: .shortened))"
        } else if calendar.isDateInYesterday(date) {
            return "Yesterday, \(date.formatted(date: .omitted, time: .shortened))"
        } else {
            return date.formatted(date: .abbreviated, time: .shortened)
        }
    }
    
    private func rateApp() {
        // Option 1: StoreKit Review Controller (In-App)
        // Best for prompting after positive actions, but valid here too.
//        if let scene = UIApplication.shared.connectedScenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene {
//            SKStoreReviewController.requestReview(in: scene)
//        }
        
        // Option 2: Direct text link to App Store "Write a Review" page
        // USE THIS if you want to force opening the App Store app.
        // Replace "YOUR_APP_ID" with your actual Apple ID of the app (e.g. 123456789)
        
        let appID = "6757456756"
        guard let url = URL(string: "https://apps.apple.com/app/id\(appID)?action=write-review") else { return }
        UIApplication.shared.open(url)
        
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

struct DeleteAccountModal: View {

    let onDelete: () -> Void
    let onCancel: () -> Void

    var body: some View {
        ZStack {
            Color.black.opacity(0.4)
                .ignoresSafeArea()

            VStack(spacing: 24) {

                ZStack {
                    Circle()
                        .fill(Color.red.opacity(0.1))
                        .frame(width: 64, height: 64)

                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundColor(.red)
                        .font(.system(size: 26))
                }

                Text("Delete Account Permanently?")
                    .font(.system(size: 20, weight: .semibold))
                    .multilineTextAlignment(.center)
                    .foregroundStyle(Color.adaptivePrimaryText)

                Text("This action cannot be undone. All your event data will be permanently removed from your account.")
                    .font(.system(size: 15))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)

                Button {
                    onDelete()
                } label: {
                    Text("Delete Account")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color.red)
                        .cornerRadius(28)
                }

                Button {
                    onCancel()
                } label: {
                    Text("Cancel")
                        .font(.system(size: 17, weight: .semibold))
                        .frame(maxWidth: .infinity)
                        .foregroundStyle(Color.primary)
                        .padding(.vertical, 16)
                        .background(
                            RoundedRectangle(cornerRadius: 28)
                                .stroke(Color.gray.opacity(0.3))
                        )
                }
            }
            .padding(24)
            .background(Color(uiColor: .systemBackground))
            .cornerRadius(24)
            .padding(.horizontal, 24)
            .shadow(radius: 20)
        }
    }
}
