import Foundation
public extension String {
    public var localized: String {
        NSLocalizedString(self, bundle: .module, comment: "")
    }
}
public enum LocalizedStringKeys {
    // MARK: - General
    public static let EmailTextField = "Email_Text_Field".localized
    public static let PasswordTextField = "Password_Text_Field".localized
    public static let SignUpButtonText = "Sign_Up_Button_Text".localized
    public static let SignOutButtonText = "Sign_Out_Button_Text".localized
    // MARK: - ConfirmationView
    public static let UserNameText = "Username_Text".localized
    public static let ConfirmationCodeTextField = "Confirmation_Code_Text_Field".localized
    public static let ConfirmButtonText = "Confirm_Button_Text".localized
    public static let UserNamePreviewText = "User_Name_Preview_Text".localized
    // MARK: - LoginView
    public static let LoginButtonText = "Login_Button_Text".localized
    public static let ImageSystemName = "Image_System_Name".localized
    public static let SignUpText = "Sign_Up_Text".localized
    // MARK: - SessionView
    // MARK: - SettingsView
    // MARK: - SignUpView
    public static let ConfirmPasswordText = "Confirm_Password_Text".localized
    public static let PasswordRequirementsText = "Password_Requirements_Text".localized
    public static let AccountExistText = "Account_Exist_Text".localized
    // MARK: - SignUpRequirements
    public static let EnterValidEmailText = "Enter_Valid_Email_Text".localized
    public static let EightCharactersText = "Eight_Characters_Text".localized
    public static let OneUppercaseText = "One_Uppercase_Text".localized
    public static let OneLowercaseText = "One_Lowercase_Text".localized
    public static let OneDigitText = "One_Digit_Text".localized
    public static let OneSpecialCharacter = "One_Special_Character".localized
    public static let PasswordMismatchText = "Password_Mismatch_Text".localized
    public static let InvalidPasswordEmailText = "Invalid_Password_Email_Text".localized
}
