import SwiftUI
import AuthenticationServices

struct LoginView: View {
    @ObservedObject var authService = AuthenticationService.shared
    @Environment(\.dismiss) private var dismiss
    
    @State private var showingPrivacy = false
    @AppStorage("hasAgreedToPrivacy") private var hasAgreedToPrivacy = false
    
    // Gradient Colors from the mockup (Cream/Peachy to Soft Purple)
    let backgroundGradient = LinearGradient(
        colors: [
            Color(red: 1.0, green: 0.98, blue: 0.94), // Light Cream
            Color(red: 0.96, green: 0.93, blue: 0.98), // Soft Transition
            Color(red: 0.95, green: 0.91, blue: 0.98)  // Pale Purple
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    var body: some View {
        ZStack {
            // Background
            backgroundGradient
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                Spacer()
                    .frame(height: 60)
                
                // Main Illustration
                LoginIllustrationView()
                    .frame(height: 300)
                    .padding(.bottom, 40)
                
                // Typography
                VStack(spacing: 8) {
                    Text("Every moment")
                        .font(.system(size: 36, weight: .heavy, design: .rounded))
                        .foregroundStyle(Color(red: 0.1, green: 0.1, blue: 0.15)) // Dark Navy/Black
                    
                    ZStack(alignment: .bottom) {
                        // Subtle highlight/underline shape if needed, or just text color
                        Text("counts")
                            .font(.system(size: 36, weight: .heavy, design: .rounded))
                            .foregroundStyle(.purple) // Golden Yellow
                        
                        // Yellow underline shape
//                        Capsule()
//                            .fill(Color(red: 1.0, green: 0.85, blue: 0.4).opacity(0.3))
//                            .frame(height: 12)
//                            .offset(y: 4)
//                            .zIndex(-1)
                    }
                }
                .padding(.bottom, 24)
                
                // Subtitle
                Text("Track your life's most anticipated\nevents in a vibrant new way.")
                    .font(.custom("Inter", size: 17)) // Fallback to system if Inter not avail
                    .lineSpacing(4)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 40)
                
                Spacer()
                
                // Action Buttons
                VStack(spacing: 16) {
                    SignInWithAppleButton(.signIn) { request in
                        request.requestedScopes = []
                    } onCompletion: { result in
                        authService.handleSignIn(result: result)
                        if authService.isAuthenticated {
                            if !hasAgreedToPrivacy {
                                showingPrivacy = true
                            } else {
                                dismiss()
                            }
                        }
                    }
                    .signInWithAppleButtonStyle(.black)
                    .frame(height: 54)
                    .clipShape(Capsule())
                    .padding(.horizontal, 40)
                    .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
                    
                    // "Continue with Email" removed as per request
                    
                    // Terms Footer
                    Text("By continuing, you agree to our\n[Terms of Service](https://example.com/terms) and [Privacy Policy](https://example.com/privacy).")
                        .font(.system(size: 13))
                        .foregroundStyle(.tertiary)
                        .tint(Color(red: 0.1, green: 0.1, blue: 0.15)) // Match dark theme color
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 20)
                        .padding(.top, 20)
                }
                .padding(.bottom, 20)
            }
        }
        .fullScreenCover(isPresented: $showingPrivacy) {
            PrivacyPolicyView(isOnboarding: true) {
                hasAgreedToPrivacy = true
                dismiss() // Dismiss Login View
            }
        }
    }
}

// MARK: - Illustration View
struct LoginIllustrationView: View {
    var body: some View {
        ZStack {
            // Floating Decorative Circles
            Circle()
                .fill(Color.yellow.opacity(0.8))
                .frame(width: 12, height: 12)
                .offset(x: -120, y: -80)
            
            Circle()
                .fill(Color.green.opacity(0.5))
                .frame(width: 8, height: 8)
                .offset(x: 60, y: -130)
            
            Circle()
                .fill(Color.purple.opacity(0.5))
                .frame(width: 16, height: 16)
                .offset(x: 100, y: 10)
            
            // White Card Background (The "App Icon" feel)
            RoundedRectangle(cornerRadius: 40, style: .continuous)
                .fill(.white)
                .frame(width: 180, height: 180)
                .shadow(color: Color.purple.opacity(0.1), radius: 30, x: 0, y: 10)
                .rotationEffect(.degrees(-5))
            
            // "Party" Badge (Pink Circle)
            Circle()
                .fill(Color(red: 1.0, green: 0.85, blue: 0.9)) // Light Pink
                .frame(width: 60, height: 60)
                .overlay {
                    Image(systemName: "party.popper.fill")
                        .foregroundStyle(Color.pink)
                        .font(.system(size: 24))
                }
                .offset(x: 60, y: -70)
                .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
            
            // Main Calendar Icon
            Image(systemName: "calendar")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 80, height: 80)
                .foregroundStyle(Color(hex: "#800080") ?? .purple)
                .fontWeight(.bold)
                .offset(x: -5, y: -10)
                .rotationEffect(.degrees(-5))
            
            // "Soon!" Badge (Blue Pill)
            HStack(spacing: 6) {
                Image(systemName: "timer")
                    .font(.system(size: 14, weight: .bold))
                Text("Soon!")
                    .font(.system(size: 14, weight: .bold))
            }
            .foregroundStyle(.blue)
            .padding(.vertical, 10)
            .padding(.horizontal, 16)
            .background(Color(red: 0.85, green: 0.92, blue: 1.0)) // Light Blue
            .clipShape(Capsule())
            .overlay(
                Capsule()
                    .stroke(.white, lineWidth: 4)
            )
            .offset(x: -50, y: 50)
            .shadow(color: .blue.opacity(0.2), radius: 8, x: 0, y: 4)
        }
    }
}

#Preview {
    LoginView()
}
