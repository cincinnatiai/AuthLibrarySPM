//
//  LoginViewModel.swift
//  Library
//
//  Created by Dionicio Cruz Velázquez on 2/5/25.
//

import SwiftUI

@available(iOS 13.0, *)
@MainActor
public class LoginViewModel: AuthViewModel {
    @Published public var email: String = ""
    @Published public var password: String = ""
    @Published private var isFaceIDInProgress = false
    @Published public var authenticationError: String?
    
    @Published public var isFaceIDEnabled: Bool {
        didSet {
            UserDefaults.standard.set(isFaceIDEnabled, forKey: "isFaceIDEnabled")
            UserDefaults.standard.synchronize()
        }
    }
    
    private let faceIDAuthenticator = FaceIDAuthenticator()
    private let keychain: KeychainManager
    
    public init(authManager: AuthManager, keychain: KeychainManager = KeychainManager()) {
        self.keychain = keychain
        self.isFaceIDEnabled = UserDefaults.standard.bool(forKey: "isFaceIDEnabled")
        super.init(authManager: authManager)
        loadCredentials()
        
        Task {
            await tryAutoLogin()
        }
    }
    
    private func tryAutoLogin() async {
        guard shouldAttemptAutoLogin() else { return }
        await attemptFaceIDLogin()
    }
    
    public func attemptFaceIDLogin() async {
        guard !isFaceIDInProgress else { return }
        isFaceIDInProgress = true
        
        do {
            let success = try await faceIDAuthenticator.authenticate()
            if success {
                if let storedEmail = keychain.get(key: "email"),
                   let storedPassword = keychain.get(key: "password") {
                    email = storedEmail
                    password = storedPassword
                    authManager.signIn(username: email, password: password)
                } else {
                    authenticationError = "No saved credentials found."
                }
            }
        } catch {
            authenticationError = error.localizedDescription
        }
        
        isFaceIDInProgress = false
    }
    
    public func login() {
        if isFaceIDEnabled {
            Task {
                await attemptFaceIDLogin()
            }
        } else {
            authManager.signIn(username: email, password: password)
            handleActionResult()
            keychain.set(email, key: "email")
        }
    }
    
    public func signUp() {
        authManager.showSignUp()
    }
    
    public func loadCredentials() {
        email = keychain.get(key: "email") ?? ""
    }
    
    override public func clearErrorMessage() {
        super.clearErrorMessage()
    }
    
    private func shouldAttemptAutoLogin() -> Bool {
        let hasLaunchedBefore = UserDefaults.standard.bool(forKey: "hasLaunchedBefore")
        let hasLoggedOut = UserDefaults.standard.bool(forKey: "hasLoggedOut")
        let wasInBackground = UserDefaults.standard.bool(forKey: "wasInBackground")
        
        if wasInBackground {
            UserDefaults.standard.set(false, forKey: "hasLaunchedBefore")
            UserDefaults.standard.set(false, forKey: "wasInBackground")
            return false
        }
        
        if !hasLaunchedBefore {
            UserDefaults.standard.set(true, forKey: "hasLaunchedBefore")
            return true
        }
        
        return !hasLoggedOut
    }
    
}
