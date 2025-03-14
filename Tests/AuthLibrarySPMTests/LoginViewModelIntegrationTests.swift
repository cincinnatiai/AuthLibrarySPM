//
//  LoginViewModelTests.swift
//  AuthenticationLibrary_Tests
//
//  Created by Dionicio Cruz Velázquez on 2/6/25.
//  Copyright © 2025 CocoaPods. All rights reserved.
//

import Testing
@testable import AuthLibrarySPM
import AWSMobileClientXCF

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
        
        await withCheckedContinuation { continuation in
            AWSMobileClient.default().initialize { _, _ in continuation.resume() }
        }
        
        self.authManager = AuthManager()
        self.authManager.isLoggedIn = false
        self.authManager.authState = .login
        self.authManager.errorMessage = nil
        self.mockTokenHandler = MockTokenHandler()
        self.mockAuthService = MockAuthService()
        self.keychain = MockKeychainValues()

        self.viewModel = LoginViewModel(authManager: authManager, keychain: keychain)
    }

    @available(iOS 16.0, *)
    @Test
    func testSuccessfulLogin() async throws {

        // Given (Provide an actual mail and password)
        viewModel.email = "your-email@mail.com"
        viewModel.password = "your-password"
        viewModel.isFaceIDEnabled = false
        mockAuthService.getTokenResult = .success("Mock-Token")
        authManager.setTokenProtocol(mockTokenHandler)

        await withCheckedContinuation { continuation in
            authManager.signIn(username: viewModel.email, password: viewModel.password)

            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                authManager.checkUserState()
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    continuation.resume()
                }
            }
        }

        #expect(authManager.isLoggedIn == true)
        #expect(authManager.authState == .session(user: "Session initiated"))
        #expect(authManager.errorMessage == nil)
    }

    @available(iOS 16.0, *)
    @Test
    func testFailedLogin() async throws {
        // Given
        viewModel.email = "wrong@example.com"
        viewModel.password = "wrong_password"
        viewModel.isFaceIDEnabled = false
        
        // When
        authManager.signIn(username: viewModel.email, password: viewModel.password)
        
        // Then
        let timeout = Date().addingTimeInterval(2.0)
        while authManager.errorMessage == nil, Date() < timeout {
            try? await Task.sleep(nanoseconds: 100_000_000)
        }
        
        #expect(authManager.errorMessage == "Incorrect username or password.")
    }

    @available(iOS 16.0, *)
    @Test
    func testSignUpNavigation() {
        viewModel.signUp()
        
        #expect(authManager.authState == .signUp)
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
        authManager.errorMessage = "Some error occurred"
        
        viewModel.clearErrorMessage()
        
        #expect(authManager.errorMessage == nil)
    }
}
