import Foundation

public struct FeatureFlags {
    
    // MARK: - Biometric Feature Toggle
    /// Toggle to enable or disable Face ID authentication globally.
    public static var isBiometricAuthEnabled: Bool {
        return false
    }
}
