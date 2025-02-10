//
//  StringErrorCasesExtension.swift
//  Library
//
//  Created by Dionicio Cruz Velázquez on 2/5/25.
//

import AWSMobileClientXCF

extension AWSMobileClientError {
    public var stringMessage: String {
        switch self {
        case .aliasExists(let message),
                .codeDeliveryFailure(let message),
                .codeMismatch(let message),
                .expiredCode(let message),
                .groupExists(let message),
                .internalError(let message),
                .invalidLambdaResponse(let message),
                .invalidOAuthFlow(let message),
                .invalidParameter(let message),
                .invalidPassword(let message),
                .invalidUserPoolConfiguration(let message),
                .limitExceeded(let message),
                .mfaMethodNotFound(let message),
                .notAuthorized(let message),
                .passwordResetRequired(let message),
                .resourceNotFound(let message),
                .scopeDoesNotExist(let message),
                .softwareTokenMFANotFound(let message),
                .tooManyFailedAttempts(let message),
                .tooManyRequests(let message),
                .unexpectedLambda(let message),
                .userLambdaValidation(let message),
                .userNotConfirmed(let message),
                .userNotFound(let message),
                .usernameExists(let message),
                .unknown(let message),
                .notSignedIn(let message),
                .identityIdUnavailable(let message),
                .guestAccessNotAllowed(let message),
                .federationProviderExists(let message),
                .cognitoIdentityPoolNotConfigured(let message),
                .unableToSignIn(let message),
                .invalidState(let message),
                .userPoolNotConfigured(let message),
                .userCancelledSignIn(let message),
                .badRequest(let message),
                .expiredRefreshToken(let message),
                .errorLoadingPage(let message),
                .securityFailed(let message),
                .idTokenNotIssued(let message),
                .idTokenAndAcceessTokenNotIssued(let message),
                .invalidConfiguration(let message),
                .deviceNotRemembered(let message):
            return message
        @unknown default: return "Unknown Error"
        }
    }
}
