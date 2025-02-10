//
//  SignUpViewModelTests.swift
//  AuthenticationLibrary_Tests
//
//  Created by Dionicio Cruz Velázquez on 2/6/25.
//  Copyright © 2025 CocoaPods. All rights reserved.
//

import Testing
@testable import AuthLibrarySPM

@Suite
@MainActor
struct SignUpViewModelTests {
    var authManager: MockAuthManager
    var viewModel: SignUpViewModel

    init() {
        self.authManager = MockAuthManager()
        self.viewModel = SignUpViewModel(authManager: authManager)
    }

    @Test
    func testSignUpSuccess() {
        // Given
        viewModel.email = "newuser@example.com"
        viewModel.password = "password123"
        viewModel.confirmPassword = "password123"

        // When
        viewModel.signUp()

        // Then
        #expect(authManager.showSignUpCalled == true)
        #expect(authManager.authState == .confirmCode(username: "newuser@example.com"))
    }

    @Test
    func testSignUpFailureDueToExistingUser() {
        // Given
        viewModel.email = "existinguser@example.com"
        viewModel.password = "password123"
        viewModel.confirmPassword = "password123"

        // When
        viewModel.signUp()

        // Then
        #expect(authManager.showSignUpCalled == true)
        #expect(authManager.authState == .login)
        #expect(authManager.errorMessage == "User already exists")
    }

    @Test
    func testSignUpFailureDueToMismatchedPasswords() {
        // Given
        viewModel.email = "newuser@example.com"
        viewModel.password = "password123"
        viewModel.confirmPassword = "password456"

        // When
        viewModel.signUp()

        // Then
        #expect(authManager.authState == .login)
    }
}
