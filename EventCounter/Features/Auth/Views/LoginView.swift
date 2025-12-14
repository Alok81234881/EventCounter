import SwiftUI
import AuthenticationServices

struct LoginView: View {
    @ObservedObject var authService = AuthenticationService.shared
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            
            Image(systemName: "lock.shield.fill")
                .font(.system(size: 80))
                .foregroundStyle(.blue)
            
            Text("Sign In to EventCounter")
                .font(.title)
                .bold()
            
            Text("Secure your events and sync them across your devices.")
                .font(.body)
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
                .padding(.horizontal)
            
            Spacer()
            
            SignInWithAppleButton(.signIn) { request in
                request.requestedScopes = []
            } onCompletion: { result in
                authService.handleSignIn(result: result)
                if authService.isAuthenticated {
                    dismiss()
                }
            }
            .signInWithAppleButtonStyle(.black)
            .frame(height: 50)
            .padding(.horizontal)
            
            Button("Not Now") {
                dismiss()
            }
            .font(.subheadline)
            .padding(.bottom)
        }
        .padding()
    }
}

#Preview {
    LoginView()
}
