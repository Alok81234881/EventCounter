import SwiftUI

struct TermsOfServiceView: View {
    @Environment(\.dismiss) private var dismiss
    
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
                    
                    // 1. Acceptance
                    VStack(alignment: .leading, spacing: 12) {
                        Text("1. Acceptance of Terms")
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundStyle(Color.adaptivePrimaryText)
                        
                        Text("By downloading or using the Pulse app, these terms will automatically apply to you. You should make sure therefore that you read them carefully before using the app.")
                            .font(.system(size: 15))
                            .foregroundStyle(.secondary)
                            .lineSpacing(4)
                    }
                    
                    // 2. Use of Service
                    VStack(alignment: .leading, spacing: 12) {
                        Text("2. Use of Service")
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundStyle(Color.adaptivePrimaryText)
                        
                        Text("Pulse is a personal utility application designed to help you track event countdowns. You are responsible for any content (event titles, notes, photos) you create within the app.")
                            .font(.system(size: 15))
                            .foregroundStyle(.secondary)
                            .lineSpacing(4)
                    }
                    
                    // 3. Local Data
                    VStack(alignment: .leading, spacing: 12) {
                        Text("3. Local Data & Privacy")
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundStyle(Color.adaptivePrimaryText)
                        
                        Text("All data is stored locally on your device or in your personal iCloud container. We do not host, view, or control your data. You are solely responsible for backing up your data (e.g., via iCloud Backup) to prevent loss.")
                            .font(.system(size: 15))
                            .foregroundStyle(.secondary)
                            .lineSpacing(4)
                    }
                    
                    // 4. IP
                    VStack(alignment: .leading, spacing: 12) {
                        Text("4. Intellectual Property")
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundStyle(Color.adaptivePrimaryText)
                        
                        Text("The app itself, and all the trade marks, copyright, database rights and other intellectual property rights related to it, belong to the developers. You are not allowed to copy, or modify the app, any part of the app, or our trademarks in any way.")
                            .font(.system(size: 15))
                            .foregroundStyle(.secondary)
                            .lineSpacing(4)
                    }
                    
                    // 5. Contact
                    VStack(alignment: .leading, spacing: 12) {
                        Text("5. Contact Us")
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundStyle(Color.adaptivePrimaryText)
                        
                        Text("If you have any questions or suggestions about our Terms and Conditions, do not hesitate to contact us about the Pulse app support.")
                            .font(.system(size: 15))
                            .foregroundStyle(.secondary)
                            .lineSpacing(4)
                    }
                    
                    Color.clear.frame(height: 50)
                }
                .padding(24)
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "chevron.left")
                        .foregroundStyle(Color.adaptivePrimaryText)
                }
            }
            
            ToolbarItem(placement: .principal) {
                Text("Terms of Service")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(Color.adaptivePrimaryText)
            }
        }
    }
}

#Preview {
    NavigationView {
        TermsOfServiceView()
    }
}
