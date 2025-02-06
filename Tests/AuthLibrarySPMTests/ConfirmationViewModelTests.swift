//
//  ConfirmationViewModelTests.swift
//  AuthenticationLibrary_Tests
//
//  Created by Dionicio Cruz Velázquez on 2/6/25.
//  Copyright © 2025 CocoaPods. All rights reserved.
//

import Testing
@testable import AuthLibrarySPM
import XCTest

@available(iOS 13.0, *)
final class ConfirmationViewModelTests: XCTestCase {
    var authManager: MockAuthManager!
    var viewModel: ConfirmationViewModel!
    
    override func setUp() {
        super.setUp()
        authManager = MockAuthManager()
        viewModel = ConfirmationViewModel(authManager: authManager, username: "example@mail.com")
    }
    
    override func tearDown() {
        authManager = nil
        viewModel = nil
        super.tearDown()
    }
    
    @MainActor
    func testConfirmSignUpSuccess() throws {
        // Given
        viewModel.confirmationCode = "123456"
        
        // When
        viewModel.confirmSignUp()
        
        // Then
        XCTAssertTrue(authManager.confirmSignUpCalled)
        XCTAssertEqual(authManager.authState, .session(user: "example@mail.com"))
    }
    
    @MainActor
    func testConfirmSignUpFail() throws {
        // Given
        viewModel.confirmationCode = "456"
        
        // When
        viewModel.confirmSignUp()
        
        // Then
        XCTAssertTrue(authManager.confirmSignUpCalled)
        XCTAssertEqual(authManager.authState, .confirmCode(username: "example@mail.com"))
        XCTAssertEqual(authManager.errorMessage, "Invalid confirmation code")
    }
    
}
