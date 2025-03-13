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
            let isAppRelaunch = UserDefaults.standard.bool(forKey: "isAppRelaunch")
            
            if isFaceIDEnabled && isAppRelaunch {
                await tryAutoLogin()
            }
        }
    }

    private func tryAutoLogin() async {
        guard shouldAttemptAutoLogin() else { return }
        await attemptFaceIDLogin()
    }

    public func attemptFaceIDLogin() {
        guard !isFaceIDInProgress else { return }
        defer { isFaceIDInProgress = false }

        Task {
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
    }

    public func login() {
        if isFaceIDEnabled {
            attemptFaceIDLogin()
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
        let isAppRelaunch = UserDefaults.standard.bool(forKey: "isAppRelaunch")

        if isAppRelaunch {
            UserDefaults.standard.set(false, forKey: "isAppRelaunch")
            return isFaceIDEnabled
        }
        return false
    }

    public func toggleFaceID(_ enabled: Bool) async {
        guard enabled else {
            isFaceIDEnabled = false
            UserDefaults.standard.set(false, forKey: "isFaceIDEnabled")
            return
        }

        do {
            let success = try await faceIDAuthenticator.authenticate()
            if success {
                isFaceIDEnabled = true
                UserDefaults.standard.set(true, forKey: "isFaceIDEnabled")
                UserDefaults.standard.set(false, forKey: "hasLoggedOut")
                await tryAutoLogin()
            } else {
                isFaceIDEnabled = false
            }
        } catch {
            authenticationError = "Face ID permission denied"
            isFaceIDEnabled = false
        }
    }
}
