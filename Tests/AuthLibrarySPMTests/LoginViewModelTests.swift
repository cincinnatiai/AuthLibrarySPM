//
//  LoginViewModelTests2.swift
//  AuthenticationLibrary_Tests
//
//  Created by Dionicio Cruz Velázquez on 2/6/25.
//  Copyright © 2025 CocoaPods. All rights reserved.
//

import Testing
@testable import AuthLibrarySPM

@Suite
@MainActor
struct LoginViewModelTests {
    var authManager: MockAuthManager
    var viewModel: LoginViewModel

    init() {
        self.authManager = MockAuthManager()
        self.viewModel = LoginViewModel(authManager: authManager)
    }

    @Test
    func testLoginSuccess() {
        // Given
        viewModel.email = "example@mail.com"
        viewModel.password = "password123_"

        // When
        viewModel.login()

        // Then
        #expect(authManager.signInCalled == true)
        #expect(authManager.authState == .session(user: "example@mail.com"))
        #expect(viewModel.showError == false)
    }

    @Test
    func testLoginFail() {
        // Given
        viewModel.email = "Example@example.com"
        viewModel.password = "password123/"

        // When
        viewModel.login()

        // Then
        #expect(authManager.signInCalled == true)
        #expect(viewModel.showError == true)
        #expect(authManager.authState == .login)
        #expect(authManager.errorMessage == "Invalid credentials")
    }

    @Test
    func testShowSignUp() {
        // When
        viewModel.signUp()

        // Then
        #expect(authManager.showSignUpCalled == true)
    }
}
