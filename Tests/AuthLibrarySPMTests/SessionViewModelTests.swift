//
//  SessionViewModelTests.swift
//  AuthenticationLibrary_Tests
//
//  Created by Dionicio Cruz Velázquez on 2/6/25.
//  Copyright © 2025 CocoaPods. All rights reserved.
//

import Testing
@testable import AuthLibrarySPM
import XCTest

@available(iOS 13.0, *)
final class SessionViewModelTests: XCTestCase {
    var authManager: MockAuthManager!
    var viewModel: SessionViewModel!
    
    override func setUp() {
        super.setUp()
        authManager = MockAuthManager()
        viewModel = SessionViewModel(authManager: authManager, user: "user@mail.com")
    }
    
    override func tearDown() {
        authManager = nil
        viewModel = nil
        super.tearDown()
    }
    
    func testInitialUser() {
        XCTAssertEqual(viewModel.user, "user@mail.com")
    }
    
    func testLogout() {
        // When
        viewModel.logout()
        
        // Then
        XCTAssertTrue(authManager.signOutCalled, "Expected signOutCalled to be true, but it was false.")
        XCTAssertEqual(authManager.authState, .login, "Expected authState to be .login, but it was \(authManager.authState).")
    }
    
}
