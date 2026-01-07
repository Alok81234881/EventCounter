import Foundation
import AuthenticationServices
import SwiftUI
import Combine

class AuthenticationService: NSObject, ObservableObject, ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {
    static let shared = AuthenticationService()
    
    @Published var isAuthenticated: Bool = false
    @Published var userId: String?
    @Published var userName: String?
    @Published var userEmail: String?
    
    override private init() {
        super.init()
        checkStatus()
    }
    
    func checkStatus() {
        if let savedId = UserDefaults.standard.string(forKey: "userId") {
            self.userId = savedId
            self.userName = UserDefaults.standard.string(forKey: "userName")
            self.userEmail = UserDefaults.standard.string(forKey: "userEmail")
            self.isAuthenticated = true
        } else {
            self.isAuthenticated = false
        }
    }
    
    func startSignIn() {
        let provider = ASAuthorizationAppleIDProvider()
        let request = provider.createRequest()
        request.requestedScopes = [.fullName, .email]
        
        let controller = ASAuthorizationController(authorizationRequests: [request])
        controller.delegate = self
        controller.presentationContextProvider = self
        controller.performRequests()
    }
    
    // MARK: - ASAuthorizationControllerDelegate
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        handleSignIn(result: .success(authorization))
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        handleSignIn(result: .failure(error))
    }
    
    // MARK: - ASAuthorizationControllerPresentationContextProviding
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first else {
            return ASPresentationAnchor()
        }
        return window
    }
    
    // MARK: - Legacy Handler (Internal)
    private func handleSignIn(result: Result<ASAuthorization, Error>) {
        switch result {
        case .success(let auth):
            if let credential = auth.credential as? ASAuthorizationAppleIDCredential {
                let userIdentifier = credential.user
                
                // Save Logic
                UserDefaults.standard.set(userIdentifier, forKey: "userId")
                
                // Name and Email are only returned on the FIRST sign in
                if let fullName = credential.fullName {
                    let name = PersonNameComponentsFormatter().string(from: fullName)
                    UserDefaults.standard.set(name, forKey: "userName")
                    self.userName = name
                }
                
                if let email = credential.email {
                    UserDefaults.standard.set(email, forKey: "userEmail")
                    self.userEmail = email
                } else if let tokenData = credential.identityToken,
                          let tokenString = String(data: tokenData, encoding: .utf8) {
                    // Fallback: Try to extract email from JWT Identity Token
                    if let jwtEmail = extractEmailFromJWT(tokenString) {
                         UserDefaults.standard.set(jwtEmail, forKey: "userEmail")
                         self.userEmail = jwtEmail
                    }
                }
                
                // Update State
                self.userId = userIdentifier
                if self.userName == nil {
                     self.userName = UserDefaults.standard.string(forKey: "userName")
                }
                if self.userEmail == nil {
                     self.userEmail = UserDefaults.standard.string(forKey: "userEmail")
                }
                
                self.isAuthenticated = true
                print("Successfully signed in as: \(userIdentifier)")
            }
        case .failure(let error):
            print("Sign in failed: \(error.localizedDescription)")
        }
    }
    
    // MARK: - JWT Helper
    private func extractEmailFromJWT(_ token: String) -> String? {
        let segments = token.components(separatedBy: ".")
        guard segments.count > 1 else { return nil }
        
        var base64String = segments[1]
            .replacingOccurrences(of: "-", with: "+")
            .replacingOccurrences(of: "_", with: "/")
        
        // Add padding
        let length = base64String.lengthOfBytes(using: .utf8)
        let requiredLength = 4 * ceil(Double(length) / 4.0)
        let paddingLength = requiredLength - Double(length)
        if paddingLength > 0 && paddingLength < 4 {
            base64String += String(repeating: "=", count: Int(paddingLength))
        }
        
        guard let data = Data(base64Encoded: base64String, options: .ignoreUnknownCharacters),
              let json = try? JSONSerialization.jsonObject(with: data, options: []),
              let dictionary = json as? [String: Any],
              let email = dictionary["email"] as? String else {
            return nil
        }
        
        return email
    }
    
    func signOut() {
        UserDefaults.standard.removeObject(forKey: "userId")
        UserDefaults.standard.removeObject(forKey: "userName")
        UserDefaults.standard.removeObject(forKey: "userEmail")
        UserDefaults.standard.removeObject(forKey: "hasAgreedToPrivacy")
        
        // Clear local event data (SQLite files)
        clearLocalData()
        
        // Keep name/email in UserDefaults so they persist for next login (Apple doesn't resend them)
        // Only clear them in deleteAccount
        
        self.userId = nil
        self.userName = nil
        self.userEmail = nil
        self.isAuthenticated = false
    }
    
    func deleteAccount() {
        // 1. Clear Auth Data
        UserDefaults.standard.removeObject(forKey: "userId")
        UserDefaults.standard.removeObject(forKey: "userName")
        UserDefaults.standard.removeObject(forKey: "userEmail")
        UserDefaults.standard.removeObject(forKey: "hasAgreedToPrivacy") // Reset onboarding
        
        // 2. Clear App Data (UserDefaults)
        if let bundleID = Bundle.main.bundleIdentifier {
            UserDefaults.standard.removePersistentDomain(forName: bundleID)
        }
        
        // 3. Clear SwiftData (File based)
        clearLocalData()
        
        // 4. Reset State
        self.userId = nil
        self.userName = nil
        self.userEmail = nil
        self.isAuthenticated = false
    }
    
    // MARK: - Helper
    private func clearLocalData() {
        if let appGroupURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.com.redonelabs.EventCounter") {
            let storeURL = appGroupURL.appendingPathComponent("EventCout.sqlite")
            let shmURL = appGroupURL.appendingPathComponent("EventCout.sqlite-shm")
            let walURL = appGroupURL.appendingPathComponent("EventCout.sqlite-wal")
            
            try? FileManager.default.removeItem(at: storeURL)
            try? FileManager.default.removeItem(at: shmURL)
            try? FileManager.default.removeItem(at: walURL)
        }
    }
}
