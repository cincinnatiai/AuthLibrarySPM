//
//  SingUpViewModel.swift
//  Library
//
//  Created by Dionicio Cruz Velázquez on 2/5/25.
//

import SwiftUI

@available(iOS 13.0, *)
public class SignUpViewModel: AuthViewModel {
    @Published public var email: String = ""
    @Published public var password: String = ""
    @Published public var confirmPassword: String = ""
    @Published public var showConfirmationCodeView: Bool = false
    
    private let keychain = KeychainManager()
    
    override public init(authManager: AuthManager) {
        super.init(authManager: authManager)
    }
    
    public func signUp() {
        guard !email.isEmpty, !password.isEmpty, password == confirmPassword else {
            authManager.errorMessage = "Please enter a valid email and matching passwords."
            handleActionResult()
            return
        }
        
        keychain.set(password, key: "password")
        keychain.set(email, key: "email")
        
        let attributes = ["email": email, "name": email]
        authManager.signUp(username: email, password: password, attributes: attributes)
        handleActionResult()
        
        if authManager.errorMessage == nil {
            showConfirmationCodeView = true
        }
    }
    
    func showLogin() {
        authManager.showLogin()
    }
}
