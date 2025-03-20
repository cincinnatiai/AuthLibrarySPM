//
//  AuthManager.swift
//  Library
//
//  Created by Dionicio Cruz Velázquez on 2/5/25.
//

import Foundation
import AWSMobileClientXCF
import Combine
import SwiftUI

@available(iOS 13.0, *)
@MainActor
open class AuthManager: ObservableObject {
    @Published public var authState: AuthState = .login
    @Published public var isLoggedIn: Bool = false
    @Published public var errorMessage: String? = nil

    private let authService: AuthServiceProtocol
    private var tokenProtocol: TokenManagerProtocol?
    private var cancellables: Set<AnyCancellable> = []

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
        handlePublisher(authService.checkUserState()) { [weak self] userState in
            guard let self = self else { return }
            if case .confirmCode = authState { return }
            self.isLoggedIn = (userState == .signedIn)
            self.authState = self.isLoggedIn ? .session(user: "Session initiated") : .login
            self.errorMessage = nil
        }
    }

    open func signUp(username: String, password: String, attributes: [String: String]) {
        handlePublisher(authService.signUp(username: username, password: password, attributes: attributes)) { [weak self] signUpResult in
            if signUpResult != .confirmed {
                self?.authState = .confirmCode(username: username)
            }
            self?.errorMessage = nil
        }
    }

    open func confirmSignUp(username: String, confirmationCode: String) {
        handlePublisher(authService.confirmSignUp(username: username, confirmationCode: confirmationCode)) { [weak self] _ in
            self?.showLogin()
        }
    }

    open func signIn(username: String, password: String) {
        handlePublisher(authService.signIn(username: username, password: password)) { [weak self] signInResult in
            if signInResult == .signedIn {
                self?.isLoggedIn = true
                self?.checkUserState()
                self?.manageToken()
            }
        }
    }

    open func signOut() {
        handlePublisher(authService.signOut()) { [weak self] in
            self?.isLoggedIn = false
            self?.checkUserState()
            self?.errorMessage = nil
        }
    }

    private func manageToken() {
        handlePublisher(authService.getTokenId()) { [weak self] token in
            guard let self, let tokenProtocol else { return }
            tokenProtocol.manageTokenId(idToken: token)
        }
    }

    public func setTokenProtocol(_ tokenProtocol: TokenManagerProtocol) {
        self.tokenProtocol = tokenProtocol
    }

    open func handleError(_ error: AuthError) {
        self.errorMessage = error.errorMessage
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
    private func handlePublisher<T>(_ publisher: AnyPublisher<T, AuthError>, success: @escaping (T) -> Void) {
        publisher
            .mapError { error -> AuthError in
                if case let .awsError(awsError) = error {
                    return self.filteredAuthError(awsError)
                }
                return .unknown
            }
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                if case .failure(let error) = completion {
                    self?.handleError(error)
                }
            }, receiveValue: { success($0) })
            .store(in: &cancellables)
    }

    private func filteredAuthError(_ error: AWSMobileClientError) -> AuthError {
        switch error {
        case .invalidPassword,
             .mfaMethodNotFound,
             .notAuthorized,
             .passwordResetRequired,
             .userNotConfirmed,
             .userNotFound,
             .usernameExists,
             .notSignedIn,
             .tooManyFailedAttempts,
             .tooManyRequests,
             .unableToSignIn,
             .aliasExists,
             .expiredCode,
             .invalidState,
             .badRequest,
             .unknown,
             .invalidParameter:
            return .awsError(error)
        default:
            return .unknown
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

extension AuthError {
    var errorMessage: String {
        switch self {
        case .awsError(let error):
            return error.stringMessage
        case .unknown:
            return "An unknown error occurred."
        }
    }
}
