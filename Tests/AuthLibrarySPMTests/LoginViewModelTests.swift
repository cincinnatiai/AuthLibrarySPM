//
//  LoginViewModelTests2.swift
//  AuthenticationLibrary_Tests
//
//  Created by Dionicio Cruz Velázquez on 2/6/25.
//  Copyright © 2025 CocoaPods. All rights reserved.
//

import Testing
@testable import AuthLibrarySPM
import XCTest

@available(iOS 13.0, *)
final class LoginViewModelTests: XCTestCase {
    
    var authManager: MockAuthManager!
    var viewModel: LoginViewModel!
    
    override func setUp() {
        super.setUp()
            authManager = MockAuthManager()
            viewModel = LoginViewModel(authManager: authManager)
    }

    override func tearDown() {
            authManager = nil
            viewModel = nil
        super.tearDown()
    }

    func testLoginSuccess() async {
        // Given
        viewModel.email = "example@mail.com"
        viewModel.password = "password123_"
        
        // When
        viewModel.login()
        
        // Then
        XCTAssertTrue(authManager.signInCalled)
        XCTAssertEqual(authManager.authState, .session(user: "example@mail.com"))
        XCTAssertFalse(viewModel.showError)
        
    }
    
    func testLoginFail() async throws {
        // Given
        viewModel.email = "Example@example.com"
        viewModel.password = "password123/"
        
        // When
        viewModel.login()
        
        // Then
        XCTAssertTrue(authManager.signInCalled)
        XCTAssertTrue(viewModel.showError)
        XCTAssertEqual(authManager.authState, .login)
        XCTAssertEqual(authManager.errorMessage, "Invalid credentials")
    }
    
    func testShowSignUp() async throws {
        // When
        viewModel.signUp()
        
        // Then
        XCTAssertTrue(authManager.showSignUpCalled)
    }
}
