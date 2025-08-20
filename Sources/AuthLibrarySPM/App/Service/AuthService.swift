//
//  AuthService.swift
//  Library
//
//  Created by Dionicio Cruz Velázquez on 2/5/25.
//

import AWSMobileClientXCF
import Combine

private typealias AWSUserState = AWSMobileClientXCF.UserState
private typealias AWSMCError  = AWSMobileClientXCF.AWSMobileClientError

@available(iOS 13.0, *)
public final class AuthService: AuthServiceProtocol {

    private let awsMobileClient: AWSMobileClient

    public init(awsmobileClient: AWSMobileClient = AWSMobileClient.default()) {
        self.awsMobileClient = awsmobileClient
    }

    // MARK: - Authentication lifecycle

    public func signUp(
        username: String,
        password: String,
        attributes: [String: String]
    ) -> AnyPublisher<SignUpConfirmationState, AuthError> {
        execute(
            operation: { self.awsMobileClient.signUp(username: username,
                                                     password: password,
                                                     userAttributes: attributes,
                                                     completionHandler: $0) },
            transform: { $0?.signUpConfirmationState }
        )
    }

    public func confirmSignUp(username: String, confirmationCode: String) -> AnyPublisher<Void, AuthError> {
        execute(
            operation: { self.awsMobileClient.confirmSignUp(username: username,
                                                            confirmationCode: confirmationCode,
                                                            completionHandler: $0) },
            transform: { _ in () }
        )
    }

    public func signIn(username: String, password: String) -> AnyPublisher<SignInState, AuthError> {
        execute(
            operation: { self.awsMobileClient.signIn(username: username,
                                                     password: password,
                                                     completionHandler: $0) },
            transform: { $0?.signInState }
        )
    }

    public func signOut() -> AnyPublisher<Void, AuthError> {
        execute(
            operation: { completion in
                self.awsMobileClient.signOut { error in
                    completion((), error)
                }
            },
            transform: { (_: Void?) in () }
        )
    }

    // MARK: - Tokens

    public func getTokenId() -> AnyPublisher<String, AuthError> {
        execute(
            operation: { self.awsMobileClient.getTokens($0) },
            transform: { tokens in tokens?.idToken?.tokenString }
        )
    }

    public func getRefreshToken() -> AnyPublisher<String, AuthError> {
        execute(
            operation: { self.awsMobileClient.getTokens($0) },
            transform: { tokens in tokens?.refreshToken?.tokenString }
        )
    }

    public func getAccessToken() -> AnyPublisher<String, AuthError> {
        execute(
            operation: { self.awsMobileClient.getTokens($0) },
            transform: { tokens in tokens?.accessToken?.tokenString }
        )
    }

    public func refreshTokens() -> AnyPublisher<(idToken: String, accessToken: String), AuthError> {
        execute(
            operation: { self.awsMobileClient.getTokens($0) },
            transform: { tokens in
                guard
                    let id = tokens?.idToken?.tokenString,
                    let ac = tokens?.accessToken?.tokenString
                else { return nil }
                return (idToken: id, accessToken: ac)
            }
        )
    }

    // MARK: - Validation for user state

    public func checkUserState() -> AnyPublisher<UserState, AuthError> {
        Future<UserState, AuthError> { [weak self] promise in
            guard let self else { return }
            // currentUserState es del tipo top-level AWSMobileClientXCF.UserState
            let awsState: AWSUserState = self.awsMobileClient.currentUserState
            promise(.success(Self.mapAWSState(awsState)))
        }
        .eraseToAnyPublisher()
    }

    // MARK: - Mapping

    private static func mapAWSState(_ s: AWSUserState) -> UserState {
        switch s {
        case .signedIn:
            return .signedIn
        case .signedOut,
             .signedOutUserPoolsTokenInvalid,
             .signedOutFederatedTokensInvalid,
             .guest,
             .unknown:
            return .signedOut
        @unknown default:
            return .signedOut
        }
    }
}

// MARK: - Helper (Publisher wrapper)

@available(iOS 13.0, *)
private func execute<T, R>(
    operation: @escaping (@escaping (R?, Error?) -> Void) -> Void,
    transform: @escaping (R?) -> T?
) -> AnyPublisher<T, AuthError> {
    Future<T, AuthError> { promise in
        operation { result, error in
            if let error {
                if let awsError = error as? AWSMCError {
                    promise(.failure(.awsError(awsError)))
                } else {
                    promise(.failure(.unknown))
                }
            } else if let value = transform(result) {
                promise(.success(value))
            } else {
                promise(.failure(.unknown))
            }
        }
    }
    .eraseToAnyPublisher()
}
