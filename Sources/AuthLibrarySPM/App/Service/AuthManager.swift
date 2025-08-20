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
import AWSCore

// MARK: - Errors
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
        case .awsError(let e): return e.stringMessage
        case .unknown:         return "Unknown auth error"
        case .tokenRefreshFailed: return "Token refresh failed"
        }
    }
}

public enum UserState { case signedIn, signedOut }
public enum SignUpResult { case confirmed, unconfirmed }
public enum SignInResult { case signedIn, nextStep }

@available(iOS 13.0, *)
@MainActor
open class AuthManager: ObservableObject {

    // MARK: Public properties
    @Published public private(set) var isLoggedIn: Bool = false
    public private(set) var authStateSubject   = CurrentValueSubject<AuthState, Never>(.login)
    public private(set) var errorSubject       = PassthroughSubject<String?, Never>()
    public private(set) var tokensReadySubject = CurrentValueSubject<Bool, Never>(false)
    public var authStatePublisher: AnyPublisher<AuthState, Never> { authStateSubject.eraseToAnyPublisher() }
    public var errorPublisher: AnyPublisher<String?, Never>       { errorSubject.eraseToAnyPublisher() }
    public var tokensReadyPublisher: AnyPublisher<Bool, Never>    { tokensReadySubject.eraseToAnyPublisher() }

    // MARK: Private properties
    private let authService: AuthServiceProtocol
    private let tokenStore: TokenManagerProtocol
    private let errorMapper: ErrorMapperProtocol
    private var cancellables = Set<AnyCancellable>()
    private var didInitializeAWS = false
    private let expirySkewSeconds: TimeInterval = 120

    // MARK: - Init
    public init(
        authService: AuthServiceProtocol = AuthService(),
        errorMapper: ErrorMapperProtocol = ErrorMapper(),
        tokenProtocol: TokenManagerProtocol
    ) {
        self.authService = authService
        self.errorMapper = errorMapper
        self.tokenStore  = tokenProtocol
        initializeAWS()
    }

    // MARK: - Public API
    open func showSignUp()  { authStateSubject.send(.signUp) }
    open func showLogin()   { authStateSubject.send(.login)  }
    open func clearErrorMessage() { errorSubject.send(nil) }
    open func handleError(_ error: AuthError) {
        errorSubject.send(error.errorMessage)
    }

    open func signUp(username: String, password: String, attributes: [String: String]) {
        handlePublisher(authService.signUp(username: username, password: password, attributes: attributes)) { [weak self] result in
            guard let self else { return }
            switch result {
            case .confirmed:
                self.errorSubject.send(nil)
                self.showLogin()
            case .unconfirmed:
                self.authStateSubject.send(.confirmCode(username: username))
                self.errorSubject.send(nil)
            case .unknown:
                break
            @unknown default:
                break
            }
        }
    }

    open func confirmSignUp(username: String, confirmationCode: String) {
        handlePublisher(authService.confirmSignUp(username: username, confirmationCode: confirmationCode)) { [weak self] _ in
            self?.showLogin()
        }
    }

    open func signIn(username: String, password: String) {
        handlePublisher(authService.checkUserState()) { [weak self] state in
            guard let self else { return }
            if state == .signedIn {
                self.setSignedIn(user: username)
                self.prepareTokensAndNotify()
                return
            }

            self.handlePublisher(self.authService.signIn(username: username, password: password)) { [weak self] r in
                guard let self else { return }
                if r == .signedIn {
                    self.setSignedIn(user: username)
                    self.prepareTokensAndNotify()
                } else {
                    self.handleError(.unknown)
                }
            }
        }
    }

    open func signOut() {
        handlePublisher(authService.signOut()) { [weak self] in
            guard let self else { return }
            self.tokenStore.clearAllTokens()
            self.isLoggedIn = false
            self.authStateSubject.send(.login)
            self.errorSubject.send(nil)
            self.tokensReadySubject.send(false)
        }
    }

    // MARK: - AWS bootstrap
    open func initializeAWS() {
        guard !didInitializeAWS else { return }
        didInitializeAWS = true

        AWSMobileClient.default().initialize { [weak self] (_, error) in
            Task { @MainActor in
                #if DEBUG
                if let error { print("AWS init error:", error.localizedDescription) }
                #endif
                self?.checkUserState()
            }
        }
    }

    open func checkUserState(userName: String = "") {
        handlePublisher(authService.checkUserState()) { [weak self] state in
            guard let self else { return }

            if case .confirmCode = self.authStateSubject.value { return }

            let signedIn = (state == .signedIn)
            self.isLoggedIn = signedIn
            self.authStateSubject.send(signedIn ? .session(user: userName) : .login)
            self.errorSubject.send(nil)

            self.tokensReadySubject.send(false)

            if signedIn {
                self.prepareTokensAndNotify()
            } else {
                self.tokensReadySubject.send(false)
            }
        }
    }

    // MARK: - Core: Tokens & readiness
    private func prepareTokensAndNotify() {
        if let id = tokenStore.getIdToken(), !id.isEmpty,
           let ac = tokenStore.getAccessToken(), !ac.isEmpty {
            tokensReadySubject.send(true)
            refreshIfNeededInBackground()
            return
        }

        retrieveIdThenAccessThenRefresh { [weak self] gotSomething in
            guard let self else { return }
            if gotSomething {
                self.tokensReadySubject.send(true)
                self.refreshIfNeededInBackground()
            } else {
                Task { [weak self] in
                    guard let self else { return }
                    let ok = await self.refreshWithRetries(maxRetries: 3, delayMs: 250)
                    self.tokensReadySubject.send(ok)
                    if !ok {
                        self.handleError(.tokenRefreshFailed)
                    }
                }
            }
        }
    }

    private func refreshIfNeededInBackground() {
        let id  = tokenStore.getIdToken()
        let ac  = tokenStore.getAccessToken()
        if isJWTExpired(id, skew: expirySkewSeconds) || isJWTExpired(ac, skew: expirySkewSeconds) {
            Task { [weak self] in
                guard let self else { return }
                _ = await self.refreshWithRetries(maxRetries: 2, delayMs: 250)
            }
        }
    }

    private func retrieveIdThenAccessThenRefresh(completion: @escaping (Bool) -> Void) {
        handlePublisher(authService.getTokenId()) { [weak self] id in
            guard let self else { completion(false); return }
            self.tokenStore.manageTokenId(idToken: id)

            self.handlePublisher(self.authService.getAccessToken()) { [weak self] acc in
                guard let self else { completion(false); return }
                self.tokenStore.manageAccessToken(accessToken: acc)

                self.handlePublisher(self.authService.getRefreshToken()) { [weak self] ref in
                    guard let self else { completion(false); return }
                    self.tokenStore.manageRefreshToken(refreshToken: ref)

                    let hasAll = (self.tokenStore.getIdToken()?.isEmpty == false) &&
                                 (self.tokenStore.getAccessToken()?.isEmpty == false)
                    completion(hasAll)
                }
            }
        }
    }

    private func refreshWithRetries(
        maxRetries: Int,
        delayMs: UInt64
    ) async -> Bool {
        var attempts = 0

        while attempts < maxRetries {
            let success: Bool = await withCheckedContinuation { cont in
                self.handlePublisher(self.authService.refreshTokens()) { pair in
                    self.tokenStore.manageTokenId(idToken: pair.idToken)
                    self.tokenStore.manageAccessToken(accessToken: pair.accessToken)
                    cont.resume(returning: true)
                } onFailure: { _ in
                    cont.resume(returning: false)
                }
            }

            if success { return true }

            attempts += 1
            try? await Task.sleep(nanoseconds: delayMs * 1_000_000)
        }

        return false
    }

    // MARK: - Helpers
    private func isJWTExpired(_ token: String?, skew: TimeInterval) -> Bool {
        guard let token, !token.isEmpty else { return true }
        let parts = token.split(separator: ".")
        guard parts.count == 3,
              let payloadData = Data(base64URLEncoded: String(parts[1])),
              let json = try? JSONSerialization.jsonObject(with: payloadData) as? [String: Any],
              let exp = json["exp"] as? TimeInterval else { return true }

        let expiry = Date(timeIntervalSince1970: exp)
        return expiry.addingTimeInterval(-skew) <= Date()
    }

    private func handlePublisher<T>(
        _ publisher: AnyPublisher<T, AuthError>,
        success: @escaping (T) -> Void,
        onFailure: ((AuthError) -> Void)? = nil
    ) {
        publisher
            .mapError { [weak self] error -> AuthError in
                guard let self else { return .unknown }
                if case let .awsError(awsError) = error { return self.errorMapper.map(awsError) }
                return error
            }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                guard let self else { return }
                if case .failure(let error) = completion {
                    self.handleError(error)
                    onFailure?(error)
                }
            } receiveValue: { value in
                success(value)
            }
            .store(in: &cancellables)
    }

    private func setSignedIn(user: String) {
        isLoggedIn = true
        authStateSubject.send(.session(user: user))
        errorSubject.send(nil)
        tokensReadySubject.send(false)
    }
}

// MARK: - Base64URL util
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
