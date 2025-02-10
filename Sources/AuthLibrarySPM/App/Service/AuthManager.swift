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
            guard let self = self else { return }
            switch result {
            case .success(let userState):
                DispatchQueue.main.async {
                    self.isLoggedIn = (userState == .signedIn)
                    self.authState = self.isLoggedIn == true ? .session(user: "Session initiated") : .login
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    self.handleError(error)
                }
            }
        }
    }
    
    open func signUp(username: String, password: String, attributes: [String: String]) {
        authService.signUp(username: username, password: password, attributes: attributes) { [weak self] result in
            switch result {
            case .success(let signUpResult):
                if signUpResult != .confirmed {
                    DispatchQueue.main.async {
                        self?.authState = .confirmCode(username: username)
                    }
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    self?.handleError(error)
                }
            }
        }
    }
    
    open func confirmSignUp(username: String, confirmationCode: String) {
        authService.confirmSignUp(username: username, confirmationCode: confirmationCode) { [weak self] result in
            switch result {
            case .success:
                DispatchQueue.main.async {
                    self?.showLogin()
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    self?.handleError(error)
                }
            }
        }
    }
    
    open func signIn(username: String, password: String) {
        authService.signIn(username: username, password: password) { [weak self] result in
            if case .success(let signInResult) = result, signInResult == .signedIn {
                DispatchQueue.main.async {
                    self?.isLoggedIn = true
                    self?.checkUserState()
                }
            } else if case .failure(let error) = result {
                DispatchQueue.main.async {
                    self?.handleError(error)
                }
            }
        }
    }
    
    open func signOut() {
        authService.signOut { [weak self] result in
            switch result {
            case .success:
                DispatchQueue.main.async {
                    self?.isLoggedIn = false
                    self?.checkUserState()
                    self?.errorMessage = nil
                }
            case .failure(let error):
                self?.handleError(error)
            }
        }
    }
    
    open func handleError(_ error: AuthError) {
        switch error {
        case .awsError(let awsError):
            DispatchQueue.main.async {
                self.errorMessage = awsError.stringMessage
            }
        case .unknown:
            DispatchQueue.main.async {
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
