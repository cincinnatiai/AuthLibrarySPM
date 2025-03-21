//
//  AuthManager.swift
//  Library
//
//  Created by Dionicio Cruz Velázquez on 2/5/25.
//

import Foundation
import AWSMobileClientXCF
import SwiftUI

@available(iOS 13.0, *)
@MainActor
open class AuthManager: ObservableObject {
    @Published public var authState: AuthState = .login
    @Published public var isLoggedIn: Bool = false
    @Published public var errorMessage: String? = nil

    private let authService: AuthServiceProtocol
    private var tokenProtocol: TokenManagerProtocol?

    public init(authService: AuthServiceProtocol = AuthService()) {
        self.authService = authService
        checkUserState()
    }

    open func showSignUp() {
        authState = .signUp
    }

    open func showLogin() {
        authState = .login
    }

    open func initializeAWS() {
        AWSMobileClient.default().initialize { (userState, error) in
            if let error = error {
                print("Error initializing AWSMobileClient: \(error.localizedDescription)")
            } else if let userState = userState {
                print("AWSMobileClient initialized with state: \(userState.rawValue)")
            }
        }
    }

    open func checkUserState() {
        authService.checkUserState { [weak self] result in
            switch result {
            case .success(let userState):
                DispatchQueue.main.async {
                    if case .confirmCode(_) = self?.authState {
                        return
                    }
                    self?.isLoggedIn = (userState == .signedIn)
                    self?.authState = self?.isLoggedIn == true ? .session(user: "Session initiated") : .login
                    self?.errorMessage = nil
                }
            case .failure(let error):
                self?.handleError(error)
            }
        }
    }

    open func signUp(username: String, password: String, attributes: [String: String]) {
        authService.signUp(username: username, password: password, attributes: attributes) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let signUpResult):
                    if signUpResult != .confirmed {
                        self?.authState = .confirmCode(username: username)
                    }
                    self?.errorMessage = nil
                case .failure(let error):
                    self?.handleError(error)
                }
            }
        }
    }

    open func confirmSignUp(username: String, confirmationCode: String) {
        authService.confirmSignUp(username: username, confirmationCode: confirmationCode) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    self?.showLogin()
                case .failure(let error):
                    self?.handleError(error)
                }
            }
        }
    }

    open func signIn(username: String, password: String) {
        authService.signIn(username: username, password: password) { [weak self] result in
            DispatchQueue.main.async { [weak self] in
                if case .success(let signInResult) = result, signInResult == .signedIn {
                    self?.isLoggedIn = true
                    self?.checkUserState()
                    self?.manageToken()
                } else if case .failure(let error) = result {
                    self?.handleError(error)
                }
            }
        }
    }

    open func signOut() {
        authService.signOut { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    self?.isLoggedIn = false
                    self?.checkUserState()
                    self?.errorMessage = nil
                case .failure(let error):
                    self?.handleError(error)
                }
            }
        }
    }

    open func handleError(_ error: AuthError) {
        DispatchQueue.main.async {
            switch error {
            case .awsError(let awsError):
                switch awsError {
                case .invalidPassword(_),
                     .limitExceeded(_),
                     .mfaMethodNotFound(_),
                     .notAuthorized(_),
                     .passwordResetRequired(_),
                     .userNotConfirmed(_),
                     .userNotFound(_),
                     .usernameExists(_),
                     .notSignedIn(_),
                     .tooManyFailedAttempts(_),
                     .tooManyRequests(_),
                     .unableToSignIn(_),
                     .aliasExists(_),
                     .expiredCode(_),
                     .invalidState(_),
                     .badRequest(_),
                     .unknown(_),
                     .invalidParameter(_):
                    self.errorMessage = awsError.message
                default:
                    self.errorMessage = "An unknown error occurred."
                }
            case .unknown:
                self.errorMessage = "An unknown error occurred."
            }
        }
    }

    open func clearErrorMessage() {
        self.errorMessage = nil
    }

    open var errorTextView: some View {
        if let errorMessage = errorMessage {
            return AnyView(Text(errorMessage)
                .foregroundColor(.red))
        } else {
            return AnyView(EmptyView())
        }
    }
}

@available(iOS 13.0, *)
extension AuthManager {
    private func manageToken() {
        self.authService.getTokenId(completion: { [weak self] tokenResult in
            guard let self else { return }
            switch tokenResult {
            case .success(let token):
                guard let tokenProtocol else { return }
                tokenProtocol.manageTokenId(idToken: token)
            case .failure(let error):
                self.handleError(error)
            }
        })
    }

    public func setTokenProtocol(_ tokenProtocol: TokenManagerProtocol) {
        self.tokenProtocol = tokenProtocol
    }
}

public enum AuthState: Equatable {
    case signUp
    case login
    case confirmCode(username: String)
    case session(user: String)
}

public enum AuthError: Error {
    case awsError(AWSMobileClientError)
    case unknown
}
