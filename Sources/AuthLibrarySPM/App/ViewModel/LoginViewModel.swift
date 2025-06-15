//
//  LoginViewModel.swift
//  Library
//
//  Created by Dionicio Cruz Velázquez on 2/5/25.
//

import Combine
import SwiftUI

@available(iOS 13.0, *)
@MainActor
public class LoginViewModel: AuthViewModel {
    @Published public var email: String = ""
    @Published public var password: String = ""
    @Published private var isFaceIDInProgress = false
    @Published public var isFaceIDEnabled: Bool { didSet { preferences.isFaceIDEnabled = isFaceIDEnabled } }

    private let faceIDAuthenticator: FaceIDAuthenticator
    private let keychain: KeychainProtocol
    private var preferences: FaceIDPreferencesProtocol

    private var cancellables = Set<AnyCancellable>()

    public init(
        authManager: AuthManager,
        keychain: KeychainProtocol = KeychainManager(),
        preferences: FaceIDPreferencesProtocol,
        faceIDAuthenticator: FaceIDAuthenticator = FaceIDAuthenticator()
    ) {
        self.keychain = keychain
        self.preferences = preferences
        self.faceIDAuthenticator = faceIDAuthenticator
        self.isFaceIDEnabled = preferences.isFaceIDEnabled
        super.init(authManager: authManager)

        loadCredentials()
    }

    public func login() async {
        if !email.isEmpty && !password.isEmpty {
            manualLogin()
        } else if isFaceIDEnabled {
            await authenticateAndLogin()
        } else {
            errorMessage = "Please enter email and password."
        }
    }

    private func manualLogin() {
        clearErrorMessage()
        observeAuthEvents()
        authManager.signIn(username: email, password: password)
    }

    public func tryAutoLogin() async {
        guard preferences.isAppRelaunch, isFaceIDEnabled else { return }
        preferences.isAppRelaunch = false
        await authenticateAndLogin()
    }

    func authenticateAndLogin() async {
        guard !isFaceIDInProgress else { return }
        isFaceIDInProgress = true

        // Check feature flag before using biometrics
        guard FeatureFlags.isBiometricAuthEnabled else {
            handleAuthenticationError("Biometric login is currently disabled.")
            return
        }

        do {
            guard try await faceIDAuthenticator.authenticate() else { return }

            guard let credentials = fetchStoredCredentials() else {
                handleAuthenticationError("No saved credentials found.")
                return
            }

            await login(with: credentials)
        } catch {
            handleAuthenticationError(error.localizedDescription)
        }
    }


    private func fetchStoredCredentials() -> (email: String, password: String)? {
        guard let email = keychain.get(key: "email"),
              let password = keychain.get(key: "password"), !email.isEmpty, !password.isEmpty else { return nil }
        return (email, password)
    }

    private func login(with credentials: (email: String, password: String)) async {
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
        } catch let error as FaceIdError {
            errorMessage = error.localizedDescription
            isFaceIDEnabled = false
        } catch {
            errorMessage = "Face ID permission denied"
            isFaceIDEnabled = false
        }
    }

    public func signUp() {
        authManager.showSignUp()
    }

    public func loadCredentials() {
        email = keychain.get(key: CredentialsKeys.email.rawValue) ?? ""
    }

    private func saveCredentials() {
        keychain.set(email, key: CredentialsKeys.email.rawValue)
        keychain.set(password, key: CredentialsKeys.password.rawValue)
    }

    override public func clearErrorMessage() {
        super.clearErrorMessage()
    }
    
    private func handleAuthenticationError(_ message: String) {
            self.errorMessage = message
            self.isFaceIDInProgress = false
    }

    private func observeAuthEvents() {
        authManager.errorPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] error in
                guard let error else { return }
                self?.errorMessage = error
            }
            .store(in: &cancellables)

        authManager.authStatePublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] state in
                if case .session = state {
                    self?.saveCredentials()
                }
            }
            .store(in: &cancellables)
    }
}
