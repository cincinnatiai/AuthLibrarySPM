//
//  SignUpViewModelTests.swift
//  AuthLibrarySPM
//
//  Created by Dionicio Cruz Velázquez on 2/6/25.
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
        #expect(authManager.authStateSubject.value == .confirmCode(username: "newuser@example.com"))
    }

    @Test
    func testSignUpFailureDueToExistingUser() {
        // Given
        var receivedError: String?

        let cancellable = authManager.errorPublisher
            .sink { receivedError = $0 }

        viewModel.email = "existinguser@example.com"
        viewModel.password = "password123"
        viewModel.confirmPassword = "password123"

        // When
        viewModel.signUp()

        // Then
        #expect(authManager.showSignUpCalled == true)
        #expect(authManager.authStateSubject.value == .login)
        #expect(receivedError == "User already exists")

            _ = cancellable
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
        #expect(authManager.authStateSubject.value == .login)
    }
}
