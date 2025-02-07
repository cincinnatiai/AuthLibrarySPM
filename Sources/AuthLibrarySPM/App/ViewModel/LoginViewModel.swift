//
//  LoginViewModel.swift
//  Library
//
//  Created by Dionicio Cruz Velázquez on 2/5/25.
//

import SwiftUI

@available(iOS 13.0, *)
public class LoginViewModel: AuthViewModel {
    @Published public var email: String = ""
    @Published public var password: String = ""
    
    private let keychain: KeychainManager

    public init(authManager: AuthManager, keychain: KeychainManager = KeychainManager()) {
        self.keychain = keychain
        super.init(authManager: authManager)
        loadCredentials()
    }

    public func login() {
        authManager.signIn(username: email, password: password)
        handleActionResult()
    }

    public func signUp() {
        authManager.showSignUp()
    }

    public func loadCredentials() {
        email = keychain.get(key: "email") ?? ""
    }

    override public func clearErrorMessage() {
        super.clearErrorMessage()
    }
}
