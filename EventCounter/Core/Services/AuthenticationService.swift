import Foundation
import AuthenticationServices
import SwiftUI
import Combine

class AuthenticationService: NSObject, ObservableObject {
    static let shared = AuthenticationService()
    
    @Published var isAuthenticated: Bool = false
    @Published var userId: String?
    
    override private init() {
        super.init()
        checkStatus()
    }
    
    func checkStatus() {
        // Simple check for now - in a real app we'd verify the credential with Apple
        if let savedId = UserDefaults.standard.string(forKey: "userId") {
            self.userId = savedId
            self.isAuthenticated = true
        } else {
            self.isAuthenticated = false
        }
    }
    
    func handleSignIn(result: Result<ASAuthorization, Error>) {
        switch result {
        case .success(let auth):
            if let credential = auth.credential as? ASAuthorizationAppleIDCredential {
                let userIdentifier = credential.user
                
                // Save Logic
                UserDefaults.standard.set(userIdentifier, forKey: "userId")
                
                // Update State
                self.userId = userIdentifier
                self.isAuthenticated = true
                print("Successfully signed in as: \(userIdentifier)")
            }
        case .failure(let error):
            print("Sign in failed: \(error.localizedDescription)")
        }
    }
    
    func signOut() {
        UserDefaults.standard.removeObject(forKey: "userId")
        self.userId = nil
        self.isAuthenticated = false
    }
}
