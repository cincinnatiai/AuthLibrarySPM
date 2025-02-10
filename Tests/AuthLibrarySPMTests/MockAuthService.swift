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

class MockAuthService: AuthServiceProtocol {
    var signUpResult: Result<SignUpConfirmationState, AuthError>?
    var confirmSignUpResult: Result<Void, AuthError>?
    var signInResult: Result<SignInState, AuthError>?
    var signOutResult: Result<Void, AuthError>?
    var checkUserStateResult: Result<UserState, AuthError>?

    func signUp(username: String, password: String, attributes: [String : String], completion: @escaping (Result<SignUpConfirmationState, AuthError>) -> Void) {
        completion(signUpResult ?? .failure(.unknown))
    }

    func confirmSignUp(username: String, confirmationCode: String, completion: @escaping (Result<Void, AuthError>) -> Void) {
        completion(confirmSignUpResult ?? .failure(.unknown))
    }

    func signIn(username: String, password: String, completion: @escaping (Result<SignInState, AuthError>) -> Void) {
        completion(signInResult ?? .failure(.unknown))
    }

    func signOut(completion: @escaping (Result<Void, AuthError>) -> Void) {
        completion(signOutResult ?? .failure(.unknown))
    }

    func checkUserState(completion: @escaping (Result<UserState, AuthError>) -> Void) {
        completion(checkUserStateResult ?? .failure(.unknown))
    }
}
