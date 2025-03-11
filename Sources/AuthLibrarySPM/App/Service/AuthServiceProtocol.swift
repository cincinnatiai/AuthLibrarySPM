//
//  AuthServiceProtocol.swift
//  Library
//
//  Created by Dionicio Cruz Velázquez on 2/5/25.
//

import Foundation
import AWSMobileClientXCF

public protocol AuthServiceProtocol {
    func signUp(username: String, password: String, attributes: [String: String], completion: @escaping (Result<SignUpConfirmationState, AuthError>) -> Void)
    func confirmSignUp(username: String, confirmationCode: String, completion: @escaping (Result<Void, AuthError>) -> Void)
    func signIn(username: String, password: String, completion: @escaping (Result<SignInState, AuthError>) -> Void)
    func signOut(completion: @escaping (Result<Void, AuthError>) -> Void)
    func checkUserState(completion: @escaping (Result<UserState, AuthError>) -> Void)
    func getIdToken(completion: @escaping (Result<String, AuthError>) -> Void)
}
