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
    public var cancellables: Set<AnyCancellable> = []

    public var authStatePublisher: AnyPublisher<AuthState, Never> { authStateSubject.eraseToAnyPublisher() }
    public var errorPublisher: AnyPublisher<String?, Never> { errorSubject.eraseToAnyPublisher() }

    private var authService: AuthServiceProtocol
    private var tokenProtocol: TokenManagerProtocol?
    private var errorMapper: ErrorMapperProtocol


    public init(authService: AuthServiceProtocol = AuthService(), errorMapper: ErrorMapperProtocol = ErrorMapper()) {
        self.authService = authService
        self.errorMapper = errorMapper
        checkUserState()
    }

    open func showSignUp() {
        authStateSubject.send(.signUp)
    }

    open func showLogin() {
        authStateSubject.send(.login)
    }

    // TODO: Move to AuthService
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
            guard let self else { return }
            if case .confirmCode = authStateSubject.value { return }
            isLoggedIn = (userState == .signedIn)
            authStateSubject.value = isLoggedIn ? .session(user: "Session initiated") : .login
            errorSubject.send(nil)
        }
    }

    open func signUp(username: String, password: String, attributes: [String: String]) {
        handlePublisher(authService.signUp(username: username, password: password, attributes: attributes)) { [weak self] signUpResult in
            guard let self else { return }
            if signUpResult != .confirmed {
                authStateSubject.send(.confirmCode(username: username))
            }
            errorSubject.send(nil)
        }
    }

    open func confirmSignUp(username: String, confirmationCode: String) {
        handlePublisher(authService.confirmSignUp(username: username, confirmationCode: confirmationCode)) { [weak self] _ in
            guard let self else { return }
            showLogin()
        }
    }

    open func signIn(username: String, password: String) {
        handlePublisher(authService.signIn(username: username, password: password)) { [weak self] signInResult in
            guard let self else { return }
            if signInResult == .signedIn {
                isLoggedIn = true
                checkUserState()
                manageTokenId()
                manageRefreshToken()
                manageAccessToken()
            }
        }
    }

    open func signOut() {
        handlePublisher(authService.signOut()) { [weak self] in
            guard let self else { return }
            isLoggedIn = false
            checkUserState()
            errorSubject.send(nil)
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

    private func manageTokenId() {
        handlePublisher(authService.getTokenId()) { [weak self] token in
            guard let self, let tokenProtocol else { return }
            tokenProtocol.manageTokenId(idToken: token)
        }
    }

    private func manageRefreshToken() {
        handlePublisher(authService.getRefreshToken()) { [weak self] token in
            guard let self, let tokenProtocol else { return }
            tokenProtocol.manageRefreshToken(refreshToken: token)
        }
    }

    private func manageAccessToken() {
        handlePublisher(authService.getAccessToken()) { [weak self] token in
            guard let self, let tokenProtocol else { return }
            tokenProtocol.manageAccessToken(accessToken: token)
        }
    }

    public func refreshTokensAndStore(completion: @escaping (Bool) -> Void) {
        authService.refreshTokens()
            .sink(receiveCompletion: { completionResult in
                switch completionResult {
                case .finished:
                    break
                case .failure(let error):
                    completion(false)
                }
            }, receiveValue: { [weak self] newTokens in
                guard let self, let tokenProtocol else {
                    completion(false)
                    return
                }
                tokenProtocol.clearAllTokens()

                tokenProtocol.manageTokenId(idToken: newTokens.idToken)
                tokenProtocol.manageAccessToken(accessToken: newTokens.accessToken)
                completion(true)
            })
            .store(in: &cancellables)
    }

    private func handlePublisher<T>(_ publisher: AnyPublisher<T, AuthError>, success: @escaping (T) -> Void) {
        publisher
            .mapError { error -> AuthError in
                if case let .awsError(awsError) = error {
                    return self.errorMapper.map(awsError)
                }
                return .unknown
            }
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                guard let self else { return }
                if case .failure(let error) = completion {
                    handleError(error)
                }
            }, receiveValue: { success($0) })
            .store(in: &cancellables)
    }
}

public enum AuthError: Error {
    case awsError(AWSMobileClientError)
    case unknown
    case tokenRefreshFailed
}

extension AuthError {
    var errorMessage: String {
        switch self {
        case .awsError(let error):
            return error.stringMessage
        case .unknown:
            return "An unknown error occurred."
        case .tokenRefreshFailed:
            return "Token Expired, please, Sign In again."
        }
    }
}

