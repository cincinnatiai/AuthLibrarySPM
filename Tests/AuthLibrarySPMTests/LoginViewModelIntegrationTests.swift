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
import XCTest

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

        viewModel.email = "metalmadnes98@gmail.com"
        viewModel.password = "A7Xacidrain@6"
        mockAuthService.getTokenResult = .success("Mock-Token")
        authManager.setTokenProtocol(mockTokenHandler)

        authManager.signIn(username: viewModel.email, password: viewModel.password)
        authManager.checkUserState()

        XCTAssertTrue(authManager.isLoggedIn, "User should be logged in")
        XCTAssertEqual(authManager.authState, .session(user: "Session initiated"), "Auth state should be session initiated")
        XCTAssertNil(authManager.errorMessage, "Error message should be nil")
    }

    @available(iOS 16.0, *)
    @Test
    func testFailedLogin() async throws {

        viewModel.email = "wrong@example.com"
        viewModel.password = "wrong"

        await withCheckedContinuation { continuation in
            authManager.signIn(username: viewModel.email, password: viewModel.password)
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) { continuation .resume() }
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
    func testLoadCredentials() async {

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
