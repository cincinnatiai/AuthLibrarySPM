//
//  MockAuthService.swift
//  AuthenticationLibrary_Tests
//
//  Created by Dionicio Cruz Velázquez on 2/5/25.
//  Copyright © 2025 CocoaPods. All rights reserved.
//
//
import Testing
@testable import AuthLibrarySPM
import AWSMobileClientXCF
import Combine

class MockAuthService: AuthServiceProtocol {

    var signUpResult: Result<SignUpConfirmationState, AuthError>?
    var confirmSignUpResult: Result<Void, AuthError>? = .success(())
    var signInResult: Result<SignInState, AuthError>?
    var signOutResult: Result<Void, AuthError>? = .success(())
    var checkUserStateResult: Result<UserState, AuthError>?
    var getTokenResult: Result<String,AuthError>?

    func signUp(username: String, password: String, attributes: [String : String]) -> AnyPublisher<SignUpConfirmationState, AuthError> {
        Future<SignUpConfirmationState, AuthError> { promise in
            if let result = self.signUpResult {
                promise(result)
            } else {
                promise(.success(.unconfirmed))
            }
        }
        .eraseToAnyPublisher()
    }

    func confirmSignUp(username: String, confirmationCode: String) -> AnyPublisher<Void, AuthError> {
        Future<Void, AuthError> { promise in
            if let result = self.confirmSignUpResult {
                promise(result)
            } else {
                promise(.success(()))
            }
        }
        .eraseToAnyPublisher()
    }

    func signIn(username: String, password: String) -> AnyPublisher<SignInState, AuthError> {
        Future<SignInState, AuthError> { promise in
            if let result = self.signInResult {
                promise(result)
            } else {
                promise(.failure(.unknown))
            }
        }
        .eraseToAnyPublisher()
    }

    func signOut() -> AnyPublisher<Void, AuthError> {
        Future<Void, AuthError> { promise in
            if let result = self.signOutResult {
                promise(result)
            } else {
                promise(.success(()))
            }
        }
        .eraseToAnyPublisher()
    }

    func checkUserState() -> AnyPublisher<UserState, AuthError> {
        Future<UserState, AuthError> { promise in
            if let result = self.checkUserStateResult {
                promise(result)
            } else {
                promise(.success(.signedOut))
            }
        }
        .eraseToAnyPublisher()
    }

    func getTokenId() -> AnyPublisher<String, AuthError> {
        Future<String, AuthError> { promise in
            if let result = self.getTokenResult {
                promise(result)
            } else {
                promise(.failure(.unknown))
            }
        }
        .eraseToAnyPublisher()
    }
}
