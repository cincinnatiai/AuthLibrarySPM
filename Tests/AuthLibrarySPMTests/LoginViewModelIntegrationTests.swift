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
    var mockAuthService: MockAuthService

    init() async {
        guard let configURL = Bundle.module.url(forResource: "awsconfiguration", withExtension: "json"),
              let data = try? Data(contentsOf: configURL),
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            fatalError("awsconfiguration.json not found or invalid")
        }

        AWSInfo.configureDefaultAWSInfo(json)

        if ProcessInfo.processInfo.environment["XCTestConfigurationFilePath"] == nil {
            await withCheckedContinuation { continuation in
                AWSMobileClient.default().initialize { _, _ in continuation.resume() }
            }
        }

        self.mockAuthService = MockAuthService()
        self.authManager = AuthManager(authService: mockAuthService)
        self.authManager.isLoggedIn = false
        self.authManager.authStateSubject.send(.login)
        self.authManager.errorSubject.send(nil)
        self.mockTokenHandler = MockTokenHandler()
        self.keychain = MockKeychainValues()

        self.viewModel = LoginViewModel(authManager: authManager, keychain: keychain, preferences: MockFaceIDPreferences())
    }

    @available(iOS 16.0, *)
    @Test
    func testSuccessfulLogin() async throws {

        // Given (Provide an actual mail and password)
        viewModel.email = "your-email@mail.com"
        viewModel.password = "your-password"
        viewModel.isFaceIDEnabled = false
        mockAuthService.signInResult = .success(.signedIn)
        mockAuthService.checkUserStateResult = .success(.signedIn)
        mockAuthService.getTokenResult = .success("Mock-Token")
        authManager.setTokenProtocol(mockTokenHandler)

        // When
        let authState = await withCheckedContinuation { continuation in
            var cancellable: AnyCancellable?
            cancellable = authManager.authStatePublisher
                .sink { state in
                    if case .session(let user) = state, user == "Session initiated" {
                        DispatchQueue.main.async {
                            continuation.resume(returning: state)
                            _ = cancellable
                        }
                    }
                }

            authManager.signIn(username: viewModel.email, password: viewModel.password)
        }

        // Then
        #expect(authManager.isLoggedIn == true)
        #expect(authState == .session(user: "Session initiated"))
    }

    @available(iOS 13.0, *)
    @Test
    func testFailedLogin() async throws {
        // Given
        viewModel.email = "wrong@example.com"
        viewModel.password = "wrong_password"
        viewModel.isFaceIDEnabled = false

        mockAuthService.signInResult = .failure(
            .awsError(.invalidParameter(message: "Incorrect username or password."))
        )

        // When
        let receivedError = await withCheckedContinuation { continuation in
            var cancellable: AnyCancellable?
            cancellable = authManager.errorPublisher
                .sink { error in
                    if let error {
                        DispatchQueue.main.async {
                            continuation.resume(returning: error)
                            _ = cancellable
                        }
                    }
                }

            authManager.signIn(username: viewModel.email, password: viewModel.password)
        }

        // Then
        #expect(receivedError == "Incorrect username or password.")
    }

    @available(iOS 16.0, *)
    @Test
    func testSignUpNavigation() {
        viewModel.signUp()

        #expect(authManager.authStateSubject.value == .signUp)
    }

    @available(iOS 16.0, *)
    @Test
    func testLoadCredentials() {

        keychain.set("saved@example.com", key: "email")

        viewModel.loadCredentials()

        #expect(viewModel.email == "saved@example.com")
    }

    @available(iOS 16.0, *)
    @Test
    func testClearErrorMessage() {
        var receivedError: String?

        let cancellable = authManager.errorPublisher
            .sink { receivedError = $0 }

        authManager.errorSubject.send("Some error occurred")

        viewModel.clearErrorMessage()

        #expect(receivedError == nil)

        _ = cancellable
    }
}
