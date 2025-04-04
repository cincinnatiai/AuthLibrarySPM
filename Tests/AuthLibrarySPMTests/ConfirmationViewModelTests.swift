//
//  ConfirmationViewModelTests.swift
//  AuthLibrarySPM
//
//  Created by Dionicio Cruz Velázquez on 2/6/25.
//

import Testing
@testable import AuthLibrarySPM

@Suite
@MainActor
struct ConfirmationViewModelTests {
    var authManager: MockAuthManager
    var viewModel: ConfirmationViewModel

    init() {
        self.authManager = MockAuthManager()
        self.viewModel = ConfirmationViewModel(authManager: authManager, username: "example@mail.com")
    }

    @Test
    func testConfirmSignUpSuccess() {
        // Given
        viewModel.confirmationCode = "123456"

        // When
        viewModel.confirmSignUp()

        // Then
        #expect(authManager.confirmSignUpCalled == true)
        #expect(authManager.authStateSubject.value == .session(user: "example@mail.com"))
    }

    @Test
    func testConfirmSignUpFail() {
        // Given
        var receivedError: String?

        let cancellable = authManager.errorPublisher
            .sink { receivedError = $0 }

        viewModel.confirmationCode = "456"

        // When
        viewModel.confirmSignUp()

        // Then
        #expect(authManager.confirmSignUpCalled == true)
        #expect(authManager.authStateSubject.value == .confirmCode(username: "example@mail.com"))
        #expect(receivedError == "Invalid confirmation code")

        _ = cancellable
    }
}
