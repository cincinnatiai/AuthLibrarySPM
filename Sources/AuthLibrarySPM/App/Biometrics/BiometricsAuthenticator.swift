//
//  BiometricsAuthenticator.swift
//  AuthLibrarySPM
//
//  Created by Dionicio Cruz Velázquez on 3/5/25.
//

import Foundation
import LocalAuthentication

@available(iOS 13.0, *)
class FaceIDAuthenticator {
    private let context = LAContext()

    @MainActor
    public func authenticate() async throws -> Bool {
        context.localizedCancelTitle = "Use Password"
        context.localizedFallbackTitle = "Use Password"
        
        guard context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil) else {
            throw FaceIdError.biometryNotAvailable
        }
        return try await withCheckedThrowingContinuation { continuation in
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: "Authenticate to access your account") { success, error in
                if success {
                    continuation.resume(returning: true)
                } else if let error = error as? LAError{
                    continuation.resume(throwing: FaceIdError.mapError(error))
                } else {
                    continuation.resume(throwing: FaceIdError.authenticationFailed(error?.localizedDescription ?? "unknown error"))
                }
            }
        }
    }
    
}

enum FaceIdError: Error {
    case biometryNotAvailable
    case authenticationFailed(String)
    case userCanceled
    case systemCanceled
    case biometryLockout
    case invalidatedContext
    
    static func mapError(_ error: LAError) -> FaceIdError {
        switch error.code {
        case .biometryNotAvailable:
            return .biometryNotAvailable
        case .biometryNotEnrolled:
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
    
    var localizedDescription: String {
        switch self {
        case .biometryNotAvailable:
            return "Face ID is not available on this device."
        case .authenticationFailed(let reason):
            return "Face ID authentication failed: \(reason)"
        case .userCanceled:
            return "Authentication canceled by the user."
        case .systemCanceled:
            return "Authentication was interrupted."
        case .biometryLockout:
            return "Too many failed attempts. Try again later or use password."
        case .invalidatedContext:
            return "Authentication session expired. Try again."
        }
    }
}
