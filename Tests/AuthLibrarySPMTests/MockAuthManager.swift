//
//  MockAuthManager.swift
//  AuthenticationLibrary_Tests
//
//  Created by Dionicio Cruz Velázquez on 2/5/25.
//  Copyright © 2025 CocoaPods. All rights reserved.
//

import AuthLibrarySPM
import Foundation

@available(iOS 13.0, *)
class MockAuthManager: AuthManager {
    init() {}
    var signInCalled = false
    var showSignUpCalled = false
    var confirmSignUpCalled = false
    var showLoginCalled = false
    var loadSessionCalled = false
    var signOutCalled = false
    
    override func signIn(username: String, password: String) {
        signInCalled = true
        if username == "example@mail.com" && password == "password123_" {
            self.authState = .session(user: username)
        } else {
            self.authState = .login
            self.errorMessage = "Invalid credentials"
        }
    }
    
    override func signUp(username: String, password: String, attributes: [String: String]) {
        showSignUpCalled = true
        if username == "newuser@example.com" {
            self.authState = .confirmCode(username: username)
        } else {
            self.errorMessage = "User already exists"
        }
    }
    
    override func confirmSignUp(username: String, confirmationCode: String) {
        confirmSignUpCalled = true
        if confirmationCode == "123456" {
            self.authState = .session(user: username)
        } else {
            self.authState = .confirmCode(username: username)
            self.errorMessage = "Invalid confirmation code"
        }
    }
    
    override func showSignUp() {
        showSignUpCalled = true
        self.authState = .signUp
    }
    
    override func signOut() {
        signOutCalled = true
        self.authState = .login
    }
}
