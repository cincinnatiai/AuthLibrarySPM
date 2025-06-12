//
//  LoginViewModelTests.swift
//  AuthLibrarySPM
//
//  Created by Dionicio Cruz Velázquez on 2/6/25.
//

import Testing
@testable import AuthLibrarySPM
import AWSMobileClientXCF
import Combine

@Suite
@MainActor
struct LoginViewModelIntegrationTests {

    var authManager: AuthManager
    var keychain: KeychainProtocol
    var viewModel: LoginViewModel
    var mockTokenHandler: MockTokenHandler
    var authService: AuthService

    init() async {
        guard let configURL = Bundle.module.url(forResource: "awsconfiguration", withExtension: "json"),
              let data = try? Data(contentsOf: configURL),
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            fatalError("awsconfiguration.json not found or invalid")
        }

        AWSInfo.configureDefaultAWSInfo(json)

        await withCheckedContinuation { continuation in
            AWSMobileClient.default().initialize { _, _ in continuation.resume() }
        }

        authService = AuthService()
        mockTokenHandler = MockTokenHandler()
        keychain = MockKeychainValues()

        authManager = AuthManager(authService: authService)
        authManager.setTokenProtocol(mockTokenHandler)

        viewModel = LoginViewModel(authManager: authManager, keychain: keychain, preferences: MockFaceIDPreferences())
    }

    @available(iOS 13.0, *)
    @Test
    func testFailedLogin() async throws {
        viewModel.email = "wrong@example.com"
        viewModel.password = "wrong_password"
        viewModel.isFaceIDEnabled = false

        let receivedError = await withCheckedContinuation { continuation in
            var cancellable: AnyCancellable?
            cancellable = authManager.errorPublisher
                .sink { error in
                    if let error {
                        continuation.resume(returning: error)
                        _ = cancellable
                    }
                }

            authManager.signIn(username: viewModel.email, password: viewModel.password)

            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                continuation.resume(returning: "timeout")
            }
        }

        #expect(receivedError == "Incorrect username or password." || receivedError == "timeout")
    }

    @available(iOS 16.0, *)
    @Test
    func testSignUpNavigation() async {
        viewModel.signUp()

        #expect(authManager.authStateSubject.value == .signUp)
    }

    @available(iOS 16.0, *)
    @Test
    func testLoadCredentials() async {
        keychain.set("saved@example.com", key: "email")

        viewModel.loadCredentials()

        #expect(viewModel.email == "saved@example.com")
    }

    @available(iOS 16.0, *)
    @Test
    func testClearErrorMessage() async {
        var receivedError: String?

        let cancellable = authManager.errorPublisher
            .sink { receivedError = $0 }

        authManager.errorSubject.send("Some error occurred")

        viewModel.clearErrorMessage()

        #expect(receivedError == nil)

        _ = cancellable
    }
}
