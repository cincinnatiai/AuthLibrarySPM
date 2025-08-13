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
    public var authStatePublisher: AnyPublisher<AuthState, Never> { authStateSubject.eraseToAnyPublisher() }
    public var errorPublisher: AnyPublisher<String?, Never> { errorSubject.eraseToAnyPublisher() }
    public private(set) var tokensReadySubject = CurrentValueSubject<Bool, Never>(false)
    public var tokensReadyPublisher: AnyPublisher<Bool, Never> { tokensReadySubject.eraseToAnyPublisher() }

    private var cancellables: Set<AnyCancellable> = []
    private var authService: AuthServiceProtocol
    private var tokenProtocol: TokenManagerProtocol
    private var errorMapper: ErrorMapperProtocol

    private var didInitializeAWS = false


    @MainActor
    public init(
        authService: AuthServiceProtocol = AuthService(),
        errorMapper: ErrorMapperProtocol = ErrorMapper(),
        tokenProtocol: TokenManagerProtocol
    ) {
        self.authService = authService
        self.errorMapper = errorMapper
        self.tokenProtocol = tokenProtocol
        initializeAWS()
    }

    open func showSignUp() {
        authStateSubject.send(.signUp)
    }

    open func showLogin() {
        authStateSubject.send(.login)
    }

    @MainActor
    open func initializeAWS() {
        guard !didInitializeAWS else { return }
        didInitializeAWS = true

        AWSMobileClient.default().initialize { [weak self] (userState, error) in
            Task { @MainActor in
    #if DEBUG
                if let error { print(LocalizedStringKeys.ErrorInitializeAWS, error.localizedDescription) }
                if let userState { print(LocalizedStringKeys.ErrorInitializeAwsState, userState.rawValue) }
    #endif
                self?.checkUserState()
            }
        }
    }

    private func prepareTokensAndNotify() {
        retrieveIdToken { [weak self] in
            guard let self else { return }
            self.retrieveAccessToken { [weak self] in
                guard let self else { return }
                self.retrieveRefreshToken()
                self.ensureFreshTokens { [weak self] _ in
                    self?.tokensReadySubject.send(true)
                }
            }
        }
    }

    open func checkUserState(userName: String = "") {
        handlePublisher(authService.checkUserState()) { [weak self] userState in
            guard let self else { return }
            if case .confirmCode = authStateSubject.value { return }
            isLoggedIn = (userState == .signedIn)
            authStateSubject.value = isLoggedIn ? .session(user: userName) : .login
            errorSubject.send(nil)

            if isLoggedIn {
                prepareTokensAndNotify()
            } else {
                authStateSubject.value = .login
                errorSubject.send(nil)
                tokensReadySubject.send(false)
            }
        }
    }

    open func signUp(username: String, password: String, attributes: [String: String]) {
        handlePublisher(authService.signUp(username: username, password: password, attributes: attributes)) { [weak self] signUpResult in
            guard let self else { return }
            if signUpResult == .confirmed {
                errorSubject.send(nil)
            } else if signUpResult == .unconfirmed {
                authStateSubject.send(.confirmCode(username: username))
                errorSubject.send(nil)
            } else {
                errorSubject.send(LocalizedStringKeys.ErrorSignupFailed)
            }
        }
    }

    open func confirmSignUp(username: String, confirmationCode: String) {
        handlePublisher(authService.confirmSignUp(username: username, confirmationCode: confirmationCode)) { [weak self] _ in
            guard let self else { return }
            showLogin()
        }
    }

    open func signIn(username: String, password: String) {
        handlePublisher(authService.checkUserState()) { [weak self] current in
            guard let self else { return }

            if current == .signedIn {
                self.isLoggedIn = true
                self.authStateSubject.send(.session(user: username))
                self.prepareTokensAndNotify()
                self.errorSubject.send(nil)
                return
            }

            self.handlePublisher(self.authService.signIn(username: username, password: password)) { [weak self] result in
                guard let self else { return }
                if result == .signedIn {
                    self.isLoggedIn = true
                    self.authStateSubject.send(.session(user: username))
                    self.prepareTokensAndNotify()
                }
            }
        }
    }

    open func signOut() {
        handlePublisher(authService.signOut()) { [weak self] in
            guard let self else { return }
            self.tokenProtocol.clearAllTokens()
            self.isLoggedIn = false
            self.authStateSubject.send(.login)
            self.errorSubject.send(nil)
            self.tokensReadySubject.send(false)
        }
    }

    open func handleError(_ error: AuthError) {
        self.errorSubject.send(error.errorMessage)
    }

    open func clearErrorMessage() {
        self.errorSubject.send(nil)
    }

}

@available(iOS 13.0, *)
extension AuthManager {

    private func retrieveIdToken(completion: (() -> Void)? = nil) {
        handlePublisher(authService.getTokenId()) { [weak self] token in
            guard let self else { return }
            tokenProtocol.manageTokenId(idToken: token)
            completion?()
        }
    }

    private func retrieveRefreshToken() {
        handlePublisher(authService.getRefreshToken()) { [weak self] token in
            guard let self else { return }
            tokenProtocol.manageRefreshToken(refreshToken: token)
        }
    }

    private func retrieveAccessToken(completion: (() -> Void)? = nil) {
        handlePublisher(authService.getAccessToken()) { [weak self] token in
            guard let self else { return }
            tokenProtocol.manageAccessToken(accessToken: token)
            completion?()
        }
    }

    public func refreshTokensAndStore(completion: @escaping (Result<Void, RefreshTokenError>) -> Void) {
        authService.refreshTokens()
            .sink(receiveCompletion: { completionResult in
                switch completionResult {
                case .finished:
                    break
                case .failure(let error):
                    completion(.failure(.networkError(error)))
                }
            }, receiveValue: { [weak self] newTokens in
                guard let self else {
                    completion(.failure(.tokenProtocolUnavailable))
                    return
                }
                tokenProtocol.manageTokenId(idToken: newTokens.idToken)
                tokenProtocol.manageAccessToken(accessToken: newTokens.accessToken)

                completion(.success(()))
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

    private func isJWTExpired(_ token: String?) -> Bool {
        guard let token, !token.isEmpty else { return true }
        let parts = token.split(separator: ".")
        guard parts.count == 3,
              let payloadData = Data(base64URLEncoded: String(parts[1])),
              let json = try? JSONSerialization.jsonObject(with: payloadData) as? [String: Any],
              let exp = json["exp"] as? TimeInterval
        else { return true }
        let expiry = Date(timeIntervalSince1970: exp)
        return expiry.addingTimeInterval(-60) <= Date()
    }

    public func ensureFreshTokens(completion: @escaping (Bool) -> Void) {
        let idTok  = tokenProtocol.getIdToken()
        let accTok = tokenProtocol.getAccessToken()

        if !isJWTExpired(idTok) && !isJWTExpired(accTok) {
            completion(true); return
        }

        refreshTokensAndStore { [weak self] result in
            switch result {
            case .success:
                completion(true)
            case .failure:
                 self?.handleError(.tokenRefreshFailed)
                 self?.signOut()
                completion(false)
            }
        }
    }
}

public enum AuthError: Error {
    case awsError(AWSMobileClientError)
    case unknown
    case tokenRefreshFailed
}

public enum RefreshTokenError: Error {
    case networkError(Error)
    case tokenProtocolUnavailable
    case unknown
}

extension AuthError {
    var errorMessage: String {
        switch self {
        case .awsError(let error):
            return error.stringMessage
        case .unknown:
            return LocalizedStringKeys.ErrorUnknownAuthError
        case .tokenRefreshFailed:
            return LocalizedStringKeys.ErrorTokenExpiredError
        }
    }
}

private extension Data {
    init?(base64URLEncoded: String) {
        var base = base64URLEncoded
            .replacingOccurrences(of: "-", with: "+")
            .replacingOccurrences(of: "_", with: "/")
        let pad = 4 - base.count % 4
        if pad < 4 { base += String(repeating: "=", count: pad) }
        self.init(base64Encoded: base)
    }
}
