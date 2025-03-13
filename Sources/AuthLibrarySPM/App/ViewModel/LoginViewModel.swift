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
    @Published public var authenticationError: String?
    @Published private var isFaceIDInProgress = false
    @Published public var isFaceIDEnabled: Bool { didSet { preferences.isFaceIDEnabled = isFaceIDEnabled } }

    private let faceIDAuthenticator: FaceIDAuthenticator
    private let keychain: KeychainProtocol
    private var preferences: FaceIDPreferencesProtocol

    public init(
        authManager: AuthManager,
        keychain: KeychainProtocol = KeychainManager(),
        preferences: FaceIDPreferencesProtocol = FaceIDPreferencesManager()
    ) {
        self.keychain = keychain
        self.preferences = preferences
        self.faceIDAuthenticator = FaceIDAuthenticator()
        self.isFaceIDEnabled = preferences.isFaceIDEnabled
        super.init(authManager: authManager)

        loadCredentials()
    }

    public func login() {
        isFaceIDEnabled ? authenticateAndLogin() : manualLogin()
    }

    private func manualLogin() {
        authManager.signIn(username: email, password: password)
        handleActionResult()
        keychain.set(email, key: "email")
    }

    func tryAutoLogin() async {
        guard preferences.isAppRelaunch, isFaceIDEnabled else { return }
        preferences.isAppRelaunch = false
        await authenticateAndLogin()
    }

    private func authenticateAndLogin() {
        guard !isFaceIDInProgress else { return }
        isFaceIDInProgress = true

        Task {
            do {
                guard try await faceIDAuthenticator.authenticate() else { return }
                guard let credentials = fetchStoredCredentials() else {
                    authenticationError = "No saved credentials found."
                    return
                }
                login(with: credentials)
            } catch {
                authenticationError = error.localizedDescription
            }
        }
    }

    private func fetchStoredCredentials() -> (email: String, password: String)? {
        guard let email = keychain.get(key: "email"),
              let password = keychain.get(key: "password") else { return nil }
        return (email, password)
    }

    private func login(with credentials: (email: String, password: String)) {
        email = credentials.email
        password = credentials.password
        authManager.signIn(username: email, password: password)
    }

    public func toggleFaceID(_ enabled: Bool) async {
        guard enabled else {
            isFaceIDEnabled = false
            return
        }

        do {
            guard try await faceIDAuthenticator.authenticate() else {
                isFaceIDEnabled = false
                return
            }
            isFaceIDEnabled = true
            preferences.hasLoggedOut = false
            await tryAutoLogin()
        } catch {
            authenticationError = "Face ID permission denied"
            isFaceIDEnabled = false
        }
    }

    public func signUp() {
        authManager.showSignUp()
    }

    public func loadCredentials() {
        email = keychain.get(key: "email") ?? ""
    }
}
