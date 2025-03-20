//
//  AuthService.swift
//  Library
//
//  Created by Dionicio Cruz Velázquez on 2/5/25.
//

import AWSMobileClientXCF
import Combine

@available(iOS 13.0, *)
public class AuthService: AuthServiceProtocol {

    private let awsMobileClient: AWSMobileClient

    public init(awsmobileClient: AWSMobileClient = AWSMobileClient.default()) {
        self.awsMobileClient = awsmobileClient
    }

    public func signUp(username: String, password: String, attributes: [String: String]) -> AnyPublisher<SignUpConfirmationState, AuthError> {
        execute (
            operation: { self.awsMobileClient.signUp(username: username, password: password, userAttributes: attributes, completionHandler: $0) },
            transform: { $0.signUpConfirmationState }
        )
    }

    public func confirmSignUp(username: String, confirmationCode: String) -> AnyPublisher<Void, AuthError> {
        execute(
            operation: { self.awsMobileClient.confirmSignUp(username: username, confirmationCode: confirmationCode, completionHandler: $0) },
            transform: { _ in () }
        )
    }

    public func signIn(username: String, password: String) -> AnyPublisher<SignInState, AuthError> {
        execute(
            operation: { self.awsMobileClient.signIn(username: username, password: password, completionHandler: $0) },
            transform: { $0.signInState }
        )
    }

    public func signOut() -> AnyPublisher<Void, AuthError> {
        execute(
            operation: { completion in
                self.awsMobileClient.signOut { error in
                    completion(nil, error)
                }
            },
            transform: { (_: Void) in () }
        )
    }

    public func getTokenId() -> AnyPublisher<String, AuthError> {
        execute(operation: { self.awsMobileClient.getTokens($0) },
                transform: { tokens in tokens?.idToken?.tokenString }
        )
    }

    public func checkUserState() -> AnyPublisher<UserState, AuthError> {
        Future<UserState, AuthError> { promise in
            let state = self.awsMobileClient.currentUserState
            promise(.success(state))
        }
        .eraseToAnyPublisher()
    }

}

@available(iOS 13.0, *)
private func execute<T, R>(
    operation: @escaping (@escaping (R?, Error?) -> Void) -> Void,
    transform: @escaping (R) -> T?
) -> AnyPublisher<T, AuthError> {
    Future<T, AuthError> { promise in
        operation { result, error in
            if let error = error as? AWSMobileClientError {
                promise(.failure(.awsError(error)))
            } else if let result = result, let transformed = transform(result) {
                promise(.success(transformed))
            } else {
                promise(.failure(.unknown))
            }
        }
    }
    .eraseToAnyPublisher()
}
