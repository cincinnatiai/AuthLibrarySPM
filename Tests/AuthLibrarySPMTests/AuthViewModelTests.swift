//
//  AuthViewModelTests.swift
//  AuthenticationLibrary_Tests
//
//  Created by Dionicio Cruz Velázquez on 2/5/25.
//  Copyright © 2025 CocoaPods. All rights reserved.
//

import Testing
@testable import AuthLibrarySPM
import XCTest

@available(iOS 13.0, *)
final class AuthViewModelTests: XCTestCase {
    var authManager: MockAuthManager!
    var viewModel: AuthViewModel!
    
    override func setUp() {
        super.setUp()
        authManager = MockAuthManager()
        viewModel = AuthViewModel(authManager: authManager)
    }
    
    override func tearDown() {
        authManager = nil
        viewModel = nil
        super.tearDown()
    }
    
    func testAuthStateChanges() {
        // Given
        authManager.authState = .login
        
        // When
        viewModel.clearErrorMessage()
        
        // Then
        XCTAssertEqual(authManager.errorMessage, nil)
    }
}
