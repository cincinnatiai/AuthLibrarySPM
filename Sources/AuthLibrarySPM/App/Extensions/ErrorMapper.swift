//
//  ErrorMapper.swift
//  AuthLibrarySPM
//
//  Created by Dionicio Cruz Velázquez on 4/4/25.
//

import AWSMobileClientXCF
import Foundation

public protocol ErrorMapperProtocol {
    func map(_ error: AWSMobileClientError) -> AuthError
}

public struct ErrorMapper: ErrorMapperProtocol {

    public init() {}

    public func map(_ error: AWSMobileClientError) -> AuthError {
        switch error {
        case .invalidPassword,
                .mfaMethodNotFound,
                .notAuthorized,
                .passwordResetRequired,
                .userNotConfirmed,
                .userNotFound,
                .usernameExists,
                .notSignedIn,
                .tooManyFailedAttempts,
                .tooManyRequests,
                .unableToSignIn,
                .aliasExists,
                .expiredCode,
                .invalidState,
                .badRequest,
                .unknown,
                .invalidParameter:
            return .awsError(error)
        default:
            return .unknown
        }
    }
}
