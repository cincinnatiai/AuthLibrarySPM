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

    var signUpRequirements: [SignUpRequirements] {
        [
            SignUpRequirements(text: LocalizedStringKeys.SignUpRequirementValidEmail) {
                self.email.range(of: #"^\S+@\S+\.\S+$"#, options: .regularExpression) != nil
            },
            SignUpRequirements(text: LocalizedStringKeys.SignUpRequirementMinLength) {
                self.password.count >= 8
            },
            SignUpRequirements(text: LocalizedStringKeys.SignUpRequirementUppercase) {
                self.password.range(of: "[A-Z]", options: .regularExpression) != nil
            },
            SignUpRequirements(text: LocalizedStringKeys.SignUpRequirementLowercase) {
                self.password.range(of: "[a-z]", options: .regularExpression) != nil
            },
            SignUpRequirements(text: LocalizedStringKeys.SignUpRequirementDigit) {
                self.password.range(of: "[0-9]", options: .regularExpression) != nil
            },
            SignUpRequirements(text: LocalizedStringKeys.SignUpRequirementSpecialCharacter) {
                self.password.range(of: "[^A-Za-z0-9]", options: .regularExpression) != nil
            },
            SignUpRequirements(text: LocalizedStringKeys.SignUpRequirementPasswordMismatch) {
                self.password == self.confirmPassword && !self.confirmPassword.isEmpty
            }
        ]
    }

    private let keychain = KeychainManager()

    override public init(authManager: AuthManager) {
        super.init(authManager: authManager)
    }

    public func signUp() {
        guard !email.isEmpty, !password.isEmpty, password == confirmPassword else {
            self.errorMessage = LocalizedStringKeys.SignUpRequirementInvalidEmailAndPassword
            handleActionResult()
            return
        }

        keychain.set(password, key: CredentialsKeys.password.rawValue)
        keychain.set(email, key: CredentialsKeys.email.rawValue)

        let attributes = ["email": email, "name": email]
        authManager.signUp(username: email, password: password, attributes: attributes)
        handleActionResult()

        if self.errorMessage == nil {
            showConfirmationCodeView = true
        }
    }

    public override func showLogin() {
        super.showLogin()
    }

    public func requirementsFulfilled() -> Bool {
        signUpRequirements.allSatisfy { $0.isValid() }
    }
}

enum CredentialsKeys: String {
    case email = "email"
    case password = "password"
}

struct SignUpRequirements {
    let text: String
    let isValid: () -> Bool
}
