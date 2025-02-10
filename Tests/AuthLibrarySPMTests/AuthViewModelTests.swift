//
//  AuthViewModelTests.swift
//  AuthenticationLibrary_Tests
//
//  Created by Dionicio Cruz Velázquez on 2/5/25.
//  Copyright © 2025 CocoaPods. All rights reserved.
//

import Testing
@testable import AuthLibrarySPM

@Suite
@MainActor
struct AuthViewModelTests {
    var authManager: MockAuthManager
    var viewModel: AuthViewModel

    init() {
        self.authManager = MockAuthManager()
        self.viewModel = AuthViewModel(authManager: authManager)
    }

    @Test
    func testAuthStateChanges() {
        // Given
        authManager.authState = .login

        // When
        viewModel.clearErrorMessage()

        // Then
        #expect(authManager.errorMessage == nil)
    }
}
