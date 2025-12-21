import SwiftUI

struct ProfileView: View {
    @Environment(\.modelContext) private var modelContext
    
    var body: some View {
        NavigationStack {
            List {
                Section {
                    HStack(spacing: 15) {
                        Image(systemName: "person.circle.fill")
                            .resizable()
                            .frame(width: 60, height: 60)
                            .foregroundStyle(.blue)
                        
                        VStack(alignment: .leading, spacing: 5) {
                            Text("User Name")
                                .font(.headline)
                            Text("user@example.com")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .padding(.vertical, 10)
                }
                
                Section("Account") {
                    Label("Sync Data", systemImage: "arrow.triangle.2.circlepath")
                    Label("Premium Subscription", systemImage: "crown.fill")
                        .foregroundStyle(.orange)
                }
                
                Section {
                    Button(role: .destructive) {
                        // Logout logic
                    } label: {
                        Text("Sign Out")
                    }
                }
            }
            .navigationTitle("Profile")
        }
    }
}

#Preview {
    ProfileView()
}
