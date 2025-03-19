//
//  AuthServiceProtocol.swift
//  Library
//
//  Created by Dionicio Cruz Velázquez on 2/5/25.
//

import Combine
import Foundation
import AWSMobileClientXCF

@available(iOS 13.0, *)
public protocol AuthServiceProtocol {
    func signUp(username: String, password: String, attributes: [String: String]) -> AnyPublisher<SignUpConfirmationState, AuthError>
    func confirmSignUp(username: String, confirmationCode: String) -> AnyPublisher<Void, AuthError>
    func signIn(username: String, password: String) -> AnyPublisher<SignInState, AuthError>
    func signOut() -> AnyPublisher<Void, AuthError>
    func checkUserState() -> AnyPublisher<UserState, AuthError>
    func getTokenId() -> AnyPublisher<String, AuthError>
}
