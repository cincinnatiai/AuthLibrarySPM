//
//  BiometricsAuthenticator.swift
//  AuthLibrarySPM
//
//  Created by Dionicio Cruz Velázquez on 3/5/25.
//

import Foundation
import LocalAuthentication

@available(iOS 13.0, *)
open class FaceIDAuthenticator {
    private let context = LAContext()

    public init() {}

    @MainActor
    open func authenticate() async throws -> Bool {
        context.localizedCancelTitle = LocalizedStringKeys.BiometricAuthenticatorUsePasswordLabel
        
        guard context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil) else {
            throw FaceIdError.biometryNotAvailable
        }
        return try await withCheckedThrowingContinuation { continuation in
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: LocalizedStringKeys.BiometricAuthenticatorAccessLabel) { success, error in
                if success {
                    continuation.resume(returning: true)
                } else if let error = error as? LAError{
                    continuation.resume(throwing: FaceIdError.mapError(error))
                } else {
                    continuation.resume(throwing: FaceIdError.authenticationFailed(error?.localizedDescription ?? LocalizedStringKeys.BiometricAuthenticatorFailedLabel))
                }
            }
        }
    }
}

public enum FaceIdError: LocalizedError {
    case biometryNotAvailable
    case authenticationFailed(String)
    case userCanceled
    case systemCanceled
    case biometryLockout
    case invalidatedContext

    static func mapError(_ error: LAError) -> FaceIdError {
        switch error.code {
        case .biometryNotAvailable, .biometryNotEnrolled:
            return .biometryNotAvailable
        case .userCancel:
            return .userCanceled
        case .systemCancel:
            return .systemCanceled
        case .biometryLockout:
            return .biometryLockout
        case .appCancel, .invalidContext:
            return .invalidatedContext
        default:
            return .authenticationFailed(error.localizedDescription)
        }
    }

    public var errorDescription: String? {
        switch self {
        case .biometryNotAvailable:
            return LocalizedStringKeys.BiometricAuthenticatorErrorBiometryNotAvailble
        case .authenticationFailed(let reason):
            return LocalizedStringKeys.BiometricAuthenticatorErrorAuthenticationFailed + reason
        case .userCanceled:
            return LocalizedStringKeys.BiometricAuthenticatorErrorUserCanceled
        case .systemCanceled:
            return LocalizedStringKeys.BiometricAuthenticatorErrorSystemCanceled
        case .biometryLockout:
            return LocalizedStringKeys.BiometricAuthenticatorErrorBiometryLockout
        case .invalidatedContext:
            return LocalizedStringKeys.BiometricAuthenticatorErrorInvalidatedContext
        }
    }
}
