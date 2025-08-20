//
//  SingUpViewModel.swift
//  Library
//
//  Created by Dionicio Cruz Velázquez on 2/5/25.
//

import SwiftUI
import Combine

@available(iOS 13.0, *)
@MainActor
public final class SignUpViewModel: ObservableObject {
    // MARK: Public properties
    @Published public var email: String = ""
    @Published public var password: String = ""
    @Published public var confirmPassword: String = ""
    @Published public var showConfirmationCodeView: Bool = false
    public let authVM: AuthViewModel
    public var authManager: AuthManager { authVM.authManager }

    // MARK: Private properties
    private let keychain = KeychainManager()

    // MARK: Initializer
    public init(authViewModel: AuthViewModel) {
        self.authVM = authViewModel
    }

    public convenience init(authManager: AuthManager) {
        self.init(authViewModel: AuthViewModel(authManager: authManager))
    }

    // MARK: Validations
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

    // MARK: - Public methods

    public func clearErrorMessage() {
          authVM.clearErrorMessage()
      }

    public func signUp() {
        guard requirementsFulfilled() else {
            authVM.errorMessage = LocalizedStringKeys.SignUpRequirementInvalidEmailAndPassword
            authVM.handleActionResult()
            return
        }

        keychain.set(password, key: CredentialsKeys.password.rawValue)
        keychain.set(email,   key: CredentialsKeys.email.rawValue)

        let attributes = ["email": email, "name": email]
        authManager.signUp(username: email, password: password, attributes: attributes)

        authVM.handleActionResult()

        if authVM.errorMessage == nil {
            showConfirmationCodeView = true
        }
    }

    public func showLogin() {
        authVM.showLogin()
    }

    @ViewBuilder
    public var errorTextView: some View { authVM.errorTextView }

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
