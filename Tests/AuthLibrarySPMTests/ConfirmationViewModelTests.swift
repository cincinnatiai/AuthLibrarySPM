//
//  ConfirmationViewModelTests.swift
//  AuthenticationLibrary_Tests
//
//  Created by Dionicio Cruz Velázquez on 2/6/25.
//  Copyright © 2025 CocoaPods. All rights reserved.
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
        #expect(authManager.authState == .session(user: "example@mail.com"))
    }

    @Test
    func testConfirmSignUpFail() {
        // Given
        viewModel.confirmationCode = "456"

        // When
        viewModel.confirmSignUp()

        // Then
        #expect(authManager.confirmSignUpCalled == true)
        #expect(authManager.authState == .confirmCode(username: "example@mail.com"))
        #expect(authManager.errorMessage == "Invalid confirmation code")
    }
}
