//
//  AuthViewModelTests.swift
//  AuthLibrarySPM
//
//  Created by Dionicio Cruz Velázquez on 2/5/25.
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
        var receivedError: String?

        let cancellable = authManager.errorPublisher
            .sink { receivedError = $0 }
        // Given
        authManager.authStateSubject.send(.login)

        // When
        viewModel.clearErrorMessage()

        // Then
        #expect(receivedError == nil)

        _ = cancellable
    }
}
