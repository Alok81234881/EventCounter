import SwiftUI

struct SettingsView: View {
    @ObservedObject var authService = AuthenticationService.shared
    @State private var showingLogin = false
    
    var body: some View {
        NavigationStack {
            List {
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
        }
    }
}

#Preview {
    SettingsView()
}
