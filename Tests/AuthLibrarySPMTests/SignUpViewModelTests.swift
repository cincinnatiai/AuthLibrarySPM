//
//  SignUpViewModelTests.swift
//  AuthenticationLibrary_Tests
//
//  Created by Dionicio Cruz Velázquez on 2/6/25.
//  Copyright © 2025 CocoaPods. All rights reserved.
//

import Testing
@testable import AuthLibrarySPM
import XCTest

@available(iOS 13.0, *)
final class SignUpViewModelTests: XCTestCase {
    var authManager: MockAuthManager!
    var viewModel: SignUpViewModel!
    
    override func setUp() {
        super.setUp()
        authManager = MockAuthManager()
        viewModel = SignUpViewModel(authManager: authManager)
    }
    
    override func tearDown() {
        authManager = nil
        viewModel = nil
        super.tearDown()
    }

    @MainActor
    func testSignUpSuccess() throws {
        // Given
        viewModel.email = "newuser@example.com"
        viewModel.password = "password123"
        viewModel.confirmPassword = "password123"
        
        // When
        viewModel.signUp()
        
        // Then
        XCTAssertTrue(authManager.showSignUpCalled)
        XCTAssertEqual(authManager.authState, .confirmCode(username: "newuser@example.com"))
    }

    @MainActor
    func testSignUpFailureDueToExistingUser() throws {
        // Given
        viewModel.email = "existinguser@example.com"
        viewModel.password = "password123"
        viewModel.confirmPassword = "password123"
        
        // When
        viewModel.signUp()
        
        // Then
        XCTAssertTrue(authManager.showSignUpCalled)
        XCTAssertEqual(authManager.authState, .login)
        XCTAssertEqual(authManager.errorMessage, "User already exists")
    }

    @MainActor
    func testSignUpFailureDueToMismatchedPasswords() {
        // Given
        viewModel.email = "newuser@example.com"
        viewModel.password = "password123"
        viewModel.confirmPassword = "password456"
        
        // When
        viewModel.signUp()
        
        // Then
        XCTAssertEqual(authManager.authState, .login)
    }
}
