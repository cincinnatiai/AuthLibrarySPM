//
//  MockAuthManager.swift
//  AuthLibrarySPM
//
//  Created by Dionicio Cruz Velázquez on 2/5/25.
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
            errorSubject.send(nil)
            authStateSubject.send(.session(user: username))
        } else {
            authStateSubject.send(.login)
            errorSubject.send("Invalid credentials")
        }
    }

    override func signUp(username: String, password: String, attributes: [String: String]) {
        showSignUpCalled = true
        if username == "newuser@example.com" {
            self.authStateSubject.send(.confirmCode(username: username))
            self.errorSubject.send(nil)
        } else {
            self.errorSubject.send("User already exists")
        }
    }

    override func confirmSignUp(username: String, confirmationCode: String) {
        confirmSignUpCalled = true
        if confirmationCode == "123456" {
            self.authStateSubject.send(.session(user: username))
            self.errorSubject.send(nil)
        } else {
            self.authStateSubject.send(.confirmCode(username: username))
            self.errorSubject.send("Invalid confirmation code")
        }
    }

    override func showSignUp() {
        showSignUpCalled = true
        self.authStateSubject.send(.signUp)
    }

    override func signOut() {
        signOutCalled = true
        self.authStateSubject.send(.login)
    }
}
