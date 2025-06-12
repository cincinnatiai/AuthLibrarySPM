//
//  MockAuthService.swift
//  AuthLibrarySPM
//
//  Created by Dionicio Cruz Velázquez on 2/5/25.
//
//

import Testing
@testable import AuthLibrarySPM
import AWSMobileClientXCF
import Combine

class MockAuthService: AuthServiceProtocol {
    private var signUpResult: Result<SignUpConfirmationState, AuthError>?
    private var confirmSignUpResult: Result<Void, AuthError>? = .success(())
    private var signInResult: Result<SignInState, AuthError>?
    private var signOutResult: Result<Void, AuthError>? = .success(())
    private var checkUserStateResult: Result<UserState, AuthError>?
    private var getTokenResult: Result<String,AuthError>?
    private var getRefreshTokenResult: Result<String,AuthError>?
    private var getAccessTokenResult: Result<String,AuthError>?
    private var getSetOfTokensResult: Result<(idToken: String, accessToken: String), AuthError>?

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
        Future <String, AuthError> { promise in
            if let result = self.getTokenResult {
                promise(result)
            } else {
                promise(.failure(.unknown))
            }
        }
        .eraseToAnyPublisher()
    }

    func getRefreshToken() -> AnyPublisher<String, AuthError> {
        Future <String, AuthError> { promise in
            if let result = self.getRefreshTokenResult {
                promise(result)
            } else {
                promise(.failure(.unknown))
            }
        }
        .eraseToAnyPublisher()
    }

    func getAccessToken() -> AnyPublisher<String, AuthError> {
        Future <String, AuthError> { promise in
            if let result = self.getAccessTokenResult {
                promise(result)
            } else {
                promise(.failure(.unknown))
            }
        }
        .eraseToAnyPublisher()
    }

    func refreshTokens() -> AnyPublisher<(idToken: String, accessToken: String), AuthError> {
        Future<(idToken: String, accessToken: String), AuthError> { promise in
            if let result = self.getSetOfTokensResult {
                promise(result)
            } else {
                promise(.failure(.unknown))
            }
        }
        .eraseToAnyPublisher()
    }
}

#if DEBUG
extension MockAuthService {
    func setSignUpResult(_ result: Result<SignUpConfirmationState, AuthError>?) {
        self.signUpResult = result
    }

    func setConfirmSignUpResult(_ result: Result<Void, AuthError>?) {
        self.confirmSignUpResult = result
    }

    func setSignInResult(_ result: Result<SignInState, AuthError>?) {
        self.signInResult = result
    }

    func setSignOutResult(_ result: Result<Void, AuthError>?) {
        self.signOutResult = result
    }

    func setCheckUserStateResult(_ result: Result<UserState, AuthError>?) {
        self.checkUserStateResult = result
    }

    func setGetTokenResult(_ result: Result<String, AuthError>?) {
        self.getTokenResult = result
    }

    func setGetRefreshTokenResult(_ result: Result<String, AuthError>?) {
        self.getRefreshTokenResult = result
    }

    func setGetAccessTokenResult(_ result: Result<String, AuthError>?) {
        self.getAccessTokenResult = result
    }

    func setGetSetOfTokensResult(_ result: Result<(idToken: String, accessToken: String), AuthError>?) {
        self.getSetOfTokensResult = result
    }
}
#endif
