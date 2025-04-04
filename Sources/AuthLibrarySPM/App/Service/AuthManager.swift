//
//  AuthManager.swift
//  Library
//
//  Created by Dionicio Cruz Velázquez on 2/5/25.
//

import Combine
import Foundation
import AWSMobileClientXCF
import Combine
import SwiftUI

@available(iOS 13.0, *)
open class AuthManager: ObservableObject {
    @Published public var isLoggedIn: Bool = false

    public private(set) var authStateSubject = CurrentValueSubject<AuthState, Never>(.login)
    public private(set) var errorSubject = PassthroughSubject<String?, Never>()

    public var authStatePublisher: AnyPublisher<AuthState, Never> {
        authStateSubject.eraseToAnyPublisher()
    }

    public var errorPublisher: AnyPublisher<String?, Never> {
        errorSubject.eraseToAnyPublisher()
    }

    private let authService: AuthServiceProtocol
    private var tokenProtocol: TokenManagerProtocol?
    private var cancellables: Set<AnyCancellable> = []

    public init(authService: AuthServiceProtocol = AuthService()) {
        self.authService = authService
        checkUserState()
    }

    open func showSignUp() {
        authStateSubject.send(.signUp)
    }

    open func showLogin() {
        authStateSubject.send(.login)
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
            if case .confirmCode = authStateSubject.value { return }
            self.isLoggedIn = (userState == .signedIn)
            self.authStateSubject.value = self.isLoggedIn ? .session(user: "Session initiated") : .login
            self.errorSubject.send(nil)
        }
    }

    open func signUp(username: String, password: String, attributes: [String: String]) {
        handlePublisher(authService.signUp(username: username, password: password, attributes: attributes)) { [weak self] signUpResult in
            if signUpResult != .confirmed {
                self?.authStateSubject.send(.confirmCode(username: username))
            }
            self?.errorSubject.send(nil)
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
            self?.errorSubject.send(nil)
        }
    }

    open func handleError(_ error: AuthError) {
        self.errorSubject.send(error.errorMessage)
    }

    public func setTokenProtocol(_ tokenProtocol: TokenManagerProtocol) {
        self.tokenProtocol = tokenProtocol
    }

    open func clearErrorMessage() {
        self.errorSubject.send(nil)
    }

}

@available(iOS 13.0, *)
extension AuthManager {

    private func manageToken() {
        handlePublisher(authService.getTokenId()) { [weak self] token in
            guard let self, let tokenProtocol else { return }
            tokenProtocol.manageTokenId(idToken: token)
        }
    }

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
