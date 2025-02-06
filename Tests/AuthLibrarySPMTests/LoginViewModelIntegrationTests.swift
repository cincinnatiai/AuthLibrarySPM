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

@available(iOS 13.0, *)
class LoginViewModelIntegrationTests: XCTestCase {
    
    var authManager: AuthManager!
    var keychain: KeychainManager!
    var viewModel: LoginViewModel!
    
    override func setUp() {
        super.setUp()

        authManager = AuthManager()
        keychain = KeychainManager()
        viewModel = LoginViewModel(authManager: authManager, keychain: keychain)
    }
    override func tearDown() {
        authManager = nil
        keychain = nil
        viewModel = nil
        super.tearDown()
    }
    
    /**
     * NOTE:
     * This test will fail unless you provide a proper email and password.
     */
    @MainActor
    func testSuccessfulLogin() {
        // Given
        viewModel.email = "dioniciocruzvelazquez@gmail.com"
        viewModel.password = "Airbag1990_"
        
        let expectation = self.expectation(description: "Login should succeed and transition to session state.")
        
        let observer = authManager.$authState.sink { state in
            print("Observed authState: \(state)")
            if case .session(let user) = state {
                XCTAssertEqual(user, "Session initiated")
                expectation.fulfill()
            }
        }
        
        // When
        viewModel.login()
        
        // Then
        waitForExpectations(timeout: 2) { error in
            if let error = error {
                XCTFail("Expectation failed with error: \(error)")
            }
        }
        
        observer.cancel()
    }
    
    @MainActor
    func testFailedLogin() {
        let signOutExpectation = self.expectation(description: "Sign out should complete")
        
        authManager.signOut()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            let userState = AWSMobileClient.default().currentUserState
            if userState == .signedOut || userState == .signedOutFederatedTokensInvalid {
                signOutExpectation.fulfill()
            } else {
                XCTFail("Failed to sign out the existing user. Current state: \(userState.rawValue)")
            }
        }
        
        wait(for: [signOutExpectation], timeout: 2)
        
        viewModel.email = "wrong@example.com"
        viewModel.password = "wrong_password"
        
        let expectation = self.expectation(description: "Login should fail with 'Incorrect username or password.'")
        
        let observer = authManager.$errorMessage.sink { errorMessage in
            if let errorMessage = errorMessage {
                XCTAssertEqual(errorMessage, "Incorrect username or password.")
                expectation.fulfill()
            }
        }
        
        viewModel.login()
        
        waitForExpectations(timeout: 10)
        
        observer.cancel()
    }
    
    func testSignUpNavigation() {
        // When
        viewModel.signUp()
        
        // Then
        XCTAssertEqual(authManager.authState, .signUp)
    }
    
    func testLoadCredentials() {
        // Given
        keychain.set("saved@example.com", key: "email")
        
        // When
        viewModel.loadCredentials()
        
        // Then
        XCTAssertEqual(viewModel.email, "saved@example.com", "Expected loaded email to be 'saved@example.com', but got \(viewModel.email)")
    }
    
    func testClearErrorMessage() {
        // Given
        authManager.errorMessage = "Some error occurred"
        
        // When
        viewModel.clearErrorMessage()
        
        // Then
        XCTAssertNil(authManager.errorMessage, "Expected error message to be nil after clearing, but it was \(authManager.errorMessage ?? "nil")")
    }
}
