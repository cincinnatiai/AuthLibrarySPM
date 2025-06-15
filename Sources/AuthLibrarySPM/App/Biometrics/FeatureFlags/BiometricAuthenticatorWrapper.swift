import Foundation

/// Protocol to ensure consistency for any biometric authentication provider.
public protocol BiometricAuthenticator {
    func authenticate() async throws -> Bool
}

/// Provides a wrapper for biometric authentication.
/// This checks the feature flag before attempting authentication.
@available(iOS 14.0, *)
public class BiometricAuthenticatorWrapper: BiometricAuthenticator {

    private let authenticator: FaceIDAuthenticator

    /// Initialize with a specific authenticator (defaults to FaceIDAuthenticator)
    public init(authenticator: FaceIDAuthenticator = FaceIDAuthenticator()) {
        self.authenticator = authenticator
    }

    public func authenticate() async throws -> Bool {
        // Check if biometric feature is enabled
        guard FeatureFlags.isBiometricAuthEnabled else {
            throw FaceIdError.biometryNotAvailable
        }

        // Attempt biometric authentication
        return try await authenticator.authenticate()
    }
}
