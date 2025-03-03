//
//  AuthService.swift
//  Library
//
//  Created by Dionicio Cruz Velázquez on 2/5/25.
//

import AWSMobileClientXCF

@available(iOS 13.0, *)
public class AuthService: AuthServiceProtocol {

    public init() { }

    public func signUp(username: String, password: String, attributes: [String: String], completion: @escaping (Result<SignUpConfirmationState, AuthError>) -> Void) {
        execute(
            operation: { AWSMobileClient.default().signUp(username: username, password: password, userAttributes: attributes, completionHandler: $0) },
            transform: { $0.signUpConfirmationState },
            completion: completion
        )
    }

    public func confirmSignUp(username: String, confirmationCode: String, completion: @escaping (Result<Void, AuthError>) -> Void) {
        execute(
            operation: { AWSMobileClient.default().confirmSignUp(username: username, confirmationCode: confirmationCode, completionHandler: $0) },
            transform: { _ in () },
            completion: completion
        )
    }

    public func signIn(username: String, password: String, completion: @escaping (Result<SignInState, AuthError>) -> Void) {
        execute(
            operation: { AWSMobileClient.default().signIn(username: username, password: password, completionHandler: $0) },
            transform: { $0.signInState },
            completion: completion
        )
    }

    public func signOut(completion: @escaping (Result<Void, AuthError>) -> Void) {
        AWSMobileClient.default().signOut { error in
            if let error = error as? AWSMobileClientError {
                completion(.failure(.awsError(error)))
            } else {
                completion(.success(()))
            }
        }
    }

    public func checkUserState(completion: @escaping (Result<UserState, AuthError>) -> Void) {
        completion(.success(AWSMobileClient.default().currentUserState))
    }
    /// Function that will get the Token from
    public func getIdToken(completion: @escaping (Result<String, AuthError>) -> Void) {
        AWSMobileClient.default().getTokens { tokens, error in
            if let error = error as? AWSMobileClientError {
                completion(.failure(.awsError(error)))
            } else if let idToken = tokens?.idToken?.tokenString {
                completion(.success(idToken))
            } else {
                completion(.failure(.unknown))
            }
        }
    }
}

private func execute<T, R>(
    operation: (@escaping (R?, Error?) -> Void) -> Void,
    transform: @escaping (R) -> T,
    completion: @escaping (Result<T, AuthError>) -> Void
) {
    operation { result, error in
        if let error = error as? AWSMobileClientError {
            completion(.failure(.awsError(error)))
        } else if let result = result {
            completion(.success(transform(result)))
        }
    }
}
