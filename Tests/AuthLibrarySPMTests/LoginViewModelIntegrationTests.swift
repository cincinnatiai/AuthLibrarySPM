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
    var keychain: KeychainManager
    var viewModel: LoginViewModel
    
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

        self.keychain = KeychainManager()
        self.viewModel = LoginViewModel(authManager: authManager, keychain: keychain)
    }
    
//    @available(iOS 16.0, *)
    @Test
    func testSuccessfulLogin() async throws {
        await withCheckedContinuation { continuation in
            AWSMobileClient.default().initialize { _, _ in continuation.resume() }
        }
        
        guard AWSMobileClient.default().currentUserState == .signedOut else { return }
        
        // Given (Provide an actual mail and password)
        viewModel.email = "dioniciocruzvelazquez@gmail.com"//"ABC@mail.com"
        viewModel.password = "Airbag1990_"//"ABC123_"
        
        await withCheckedContinuation { continuation in
            authManager.signIn(username: viewModel.email, password: viewModel.password)
            DispatchQueue.main.asyncAfter(deadline: .now() + 5) { continuation.resume() }
        }
        
        #expect(authManager.authState == .session(user: "Session initiated"))
        #expect(authManager.isLoggedIn == true)
        #expect(authManager.errorMessage == nil)
    }
    
    @available(iOS 16.0, *)
    @Test
    func testFailedLogin() async throws {
        authManager.signOut()
        try await Task.sleep(for: .milliseconds(100))
        
        // Given
        viewModel.email = "wrong@example.com"
        viewModel.password = "wrong_password"
        
        authManager.signIn(username: viewModel.email, password: viewModel.password)
        try await Task.sleep(for: .milliseconds(100))
        
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
