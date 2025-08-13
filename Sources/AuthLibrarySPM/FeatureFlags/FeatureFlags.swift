@MainActor
public class FeatureFlags {
    public static let shared = FeatureFlags()

    public private(set) var isBiometricLoginEnabled: Bool = false

    public func setBiometricEnabled(_ enabled: Bool) {
        isBiometricLoginEnabled = enabled
    }

    private init() {}
}
