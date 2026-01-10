import SwiftUI

struct PrivacyPolicyView: View {
    @Environment(\.dismiss) private var dismiss
    var isOnboarding: Bool = false
    var onAgree: (() -> Void)?
    
    
    var body: some View {
        ZStack(alignment: .bottom) {
            Color(uiColor: .systemBackground).ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 24) {
                    
                    // Last Updated Pill
                    HStack {
                        Spacer()
                        Text("LAST UPDATED: JANUARY 05, 2026")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundStyle(Color(red: 0.6, green: 0.5, blue: 0.4))
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(Color(red: 0.96, green: 0.93, blue: 0.88)) // Beige
                            .clipShape(Capsule())
                        Spacer()
                    }
                    .padding(.top, 20)
                    
                    // 1. Data Collection and Usage
                    VStack(alignment: .leading, spacing: 12) {
                        Text("1. Data Collection and Usage")
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundStyle(Color.adaptivePrimaryText)
                        
                        Text("We do not collect, store, or transmit your personal data to any external servers. All data processing happens locally on your device or via your personal iCloud account.")
                            .font(.system(size: 15))
                            .foregroundStyle(.secondary)
                            .lineSpacing(4)
                        
                        // 1.1 Calendar
                        Text("1.1 Calendar Data")
                            .font(.headline)
                            .foregroundStyle(Color.adaptivePrimaryText)
                            .padding(.top, 4)
                        Text("Access: We request access to your device's Calendar to allow you to import events into the app.\nUsage: This data is read only for the purpose of creating local Event counters. We do not transmit your calendar events to us or any third parties.")
                            .font(.system(size: 15))
                            .foregroundStyle(.secondary)
                            .lineSpacing(4)
                        
                        // 1.2 Location
                        Text("1.2 Location Data")
                            .font(.headline)
                            .foregroundStyle(Color.adaptivePrimaryText)
                            .padding(.top, 4)
                        Text("Usage: You may use the location search feature to attach a location name to an event.\nProcessing: Search queries are processed by Apple Maps services to provide results. We do not track or store your precise location coordinates permanently.")
                            .font(.system(size: 15))
                            .foregroundStyle(.secondary)
                            .lineSpacing(4)
                        
                        // 1.3 Account
                        Text("1.3 Account Information")
                            .font(.headline)
                            .foregroundStyle(Color.adaptivePrimaryText)
                            .padding(.top, 4)
                        Text("Sign in with Apple: We may offer \"Sign in with Apple\" for authentication.\nStorage: Any user identifiers (such as your User ID) provided by this service are stored locally on your device to manage your session. We do not maintain a user database on our servers.")
                            .font(.system(size: 15))
                            .foregroundStyle(.secondary)
                            .lineSpacing(4)
                    }
                    
                    // 2. Data Storage
                    VStack(alignment: .leading, spacing: 12) {
                        Text("2. Data Storage")
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundStyle(Color.adaptivePrimaryText)
                        
                        Text("All events, notes, and preferences you create in Pulse are stored:\n\n• Locally on your device using on-device database technologies (SwiftData).\n• In your personal iCloud (if signed in): Data is securely stored in your private iCloud container using CloudKit. This allows syncing across devices. We do not have access to this data.")
                            .font(.system(size: 15))
                            .foregroundStyle(.secondary)
                            .lineSpacing(4)
                    }
                    
                    // 3. Third-Party Services
                    VStack(alignment: .leading, spacing: 12) {
                        Text("3. Third-Party Services")
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundStyle(Color.adaptivePrimaryText)
                        
                        Text("We use standard iOS frameworks provided by Apple (such as UserNotifications, WidgetKit, and MapKit). Using these services is subject to Apple’s privacy policies.")
                            .font(.system(size: 15))
                            .foregroundStyle(.secondary)
                            .lineSpacing(4)
                    }
                    
                    // 4. Contact Us
                    VStack(alignment: .leading, spacing: 12) {
                        Text("4. Contact Us")
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundStyle(Color.adaptivePrimaryText)
                        
                        Text("If you have any questions about this Privacy Policy, please contact us about the Pulse app support.")
                            .font(.system(size: 15))
                            .foregroundStyle(.secondary)
                            .lineSpacing(4)
                    }
                    
                    // Online Privacy Policy Link
                    VStack(alignment: .leading, spacing: 12) {
                        Link(destination: URL(string: "https://redonelabs.in/products/pulse-ticker/privacy")!) {
                            HStack {
                                Text("View Online Privacy Policy")
                                    .font(.system(size: 15, weight: .medium))
                                Image(systemName: "arrow.up.right.square")
                                    .font(.system(size: 14))
                            }
                            .foregroundStyle(Color.purple)
                        }
                    }
                    
                    // Spacer for bottom button
                    if isOnboarding {
                        Color.clear.frame(height: 100)
                    }
                }
                .padding(24)
            }
            
            // Bottom Action Button (Only for onboarding/agreement flow)
            if isOnboarding {
                VStack(spacing: 12) {
                    Button(action: {
                        onAgree?()
                        dismiss()
                    }) {
                        HStack {
                            Text("I Agree & Continue")
                                .font(.system(size: 18, weight: .bold))
                            Image(systemName: "checkmark.circle.fill")
                                .font(.headline)
                        }
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(
                            LinearGradient(
                                colors: [Color.purple, Color.purple],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .clipShape(Capsule())
                        .shadow(color: Color.orange.opacity(0.3), radius: 10, y: 5)
                    }
                    
                    Text("By tapping \"I Agree & Continue\", you acknowledge that you have read and understood the Privacy Policy.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 20)
                }
                .padding(24)
                .background(
                    LinearGradient(
                        colors: [Color(uiColor: .systemBackground).opacity(0), Color(uiColor: .systemBackground)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .frame(height: 150)
                )
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            if !isOnboarding {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "chevron.left")
                            .foregroundStyle(Color.adaptivePrimaryText)
                    }
                }
            }
            
            ToolbarItem(placement: .principal) {
                Text("Privacy Policy")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(Color.adaptivePrimaryText)
            }
        }
    }
}

struct InfoRow: View {
    let icon: String
    let color: Color
    let text: String
    
    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.2))
                    .frame(width: 32, height: 32)
                Image(systemName: icon)
                    .foregroundStyle(color)
                    .font(.system(size: 14))
            }
            
            Text(text)
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(.primary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}

#Preview {
    PrivacyPolicyView(isOnboarding: true)
}
