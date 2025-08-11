import Foundation
public extension String {
    public var localized: String {
        NSLocalizedString(self, bundle: .module, comment: "")
    }
}
public enum LocalizedStringKeys {
    // MARK: - General
    public static let GeneralEmailTextPlaceHolder = "General_EmailTextPlaceHolder".localized
    public static let GeneralPasswordTexPlaceHolder = "General_PasswordTexPlaceHolder".localized
    public static let GeneralLoginButton = "General_LoginButton".localized
    public static let GeneralSignUpButton = "General_SignUpButton".localized
    public static let GeneralSignOutButton = "General_SignOutButton".localized
    // MARK: - ConfirmationView
    public static let ConfirmationViewUsernameLabel = "ConfirmationView_UsernameLabel".localized
    public static let ConfirmationViewCodeTextField = "ConfirmationView_CodeTextField".localized
    public static let ConfirmationViewConfirmButton = "ConfirmationView_ConfirmButton".localized
    public static let ConfirmationViewUsernamePreview = "ConfirmationView_UsernamePreview".localized
    // MARK: - LoginView
    public static let LoginViewFaceIDImageSystemName = "LoginView_FaceIDImageSystemName".localized
    public static let LoginViewSignUpPrompt = "LoginView_SignUpPrompt".localized
    // MARK: - SignUpView
    public static let SignUpViewConfirmPasswordPlaceHolder = "SignUpView_ConfirmPasswordPlaceHolder".localized
    public static let SignUpViewPasswordRequirementsLabel = "SignUpView_PasswordRequirementsLabel".localized
    public static let SignUpViewAccountExistsPrompt = "SignUpView_AccountExistsPrompt".localized
    // MARK: - SignUpRequirements
    public static let SignUpRequirementValidEmail = "SignUpRequirement_ValidEmail".localized
    public static let SignUpRequirementMinLength = "SignUpRequirement_MinLength".localized
    public static let SignUpRequirementUppercase = "SignUpRequirement_Uppercase".localized
    public static let SignUpRequirementLowercase = "SignUpRequirement_Lowercase".localized
    public static let SignUpRequirementDigit = "SignUpRequirement_Digit".localized
    public static let SignUpRequirementSpecialCharacter = "SignUpRequirement_SpecialCharacter".localized
    public static let SignUpRequirementPasswordMismatch = "SignUpRequirement_PasswordMismatch".localized
    public static let SignUpRequirementInvalidEmailAndPassword = "SignUpRequirement_InvalidEmailAndPassword".localized
    // MARK: - Error Handling
    public static let ErrorInitializeAWS = "Error_InitializeAWS".localized
    public static let ErrorInitializeAwsState = "Error_InitializeAwsState".localized
    public static let ErrorSignupFailed = "Error_SignupFailed".localized
    public static let ErrorUnknownAuthError = "Error_UnknownAuthError".localized
    public static let ErrorTokenExpiredError = "Error_TokenExpiredError".localized
    // MARK: - Biometric Authenticator Module
    public static let BiometricAuthenticatorUsePasswordLabel = "BiometricAuthenticator_UsePasswordAccountLabel".localized
    public static let BiometricAuthenticatorAccessLabel = "BiometricAuthenticator_AccessAccountLabel".localized
    public static let BiometricAuthenticatorFailedLabel = "BiometricAuthenticator_FailedLabel".localized
    // MARK: - Biometric Authenticator Error Handling
    public static let BiometricAuthenticatorErrorBiometryNotAvailble = "BiometricAuthenticatorError_BiometryNotAvailble".localized
    public static let BiometricAuthenticatorErrorAuthenticationFailed = "BiometricAuthenticatorError_AuthenticationFailed".localized
    public static let BiometricAuthenticatorErrorUserCanceled = "BiometricAuthenticatorError_ErrorUserCanceled".localized
    public static let BiometricAuthenticatorErrorSystemCanceled = "BiometricAuthenticatorError_ErrorSystemCanceled".localized
    public static let BiometricAuthenticatorErrorBiometryLockout = "BiometricAuthenticatorError_ErrorBiometryLockout".localized
    public static let BiometricAuthenticatorErrorInvalidatedContext = "BiometricAuthenticatorError_ErrorInvalidatedContext".localized
    
}
