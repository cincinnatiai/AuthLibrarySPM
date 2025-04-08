import AWSMobileClientXCF
import SwiftUI

@available(iOS 17.0, *)
public struct AuthApp<SessionViewType: View, LoginViewType: View>: View {

    @ObservedObject private var authManager: AuthManager
    @ObservedObject private var authViewModel: AuthViewModel
    @StateObject private var appLifecycleObserver = AppLifecycleObserver()
    private let sessionViewProvider: (String) -> SessionViewType
    private let loginViewProvider: (LoginViewModel) -> LoginViewType

    public init(
        authManager: AuthManager,
        authviewModel: AuthViewModel,
        @ViewBuilder loginView: @escaping (LoginViewModel) -> LoginViewType = { viewModel in  LoginView(viewModel: viewModel)},
        @ViewBuilder sessionView: @escaping (String) -> SessionViewType
    ) {
        self.authManager = authManager
        self.authViewModel = authviewModel
        self.sessionViewProvider = sessionView
        self.loginViewProvider = loginView
    }

    public var body: some View {
        VStack {
            switch authViewModel.authState {
            case .login:
                let viewModel = LoginViewModel(authManager: authManager, preferences: FaceIDPreferencesManager())
                loginViewProvider(viewModel)
            case .signUp:
                SignUpView(viewModel: SignUpViewModel(authManager: authManager))
            case .confirmCode(let username):
                ConfirmationView(viewModel: ConfirmationViewModel(authManager: authManager, username: username))
            case .session(let user):
                sessionViewProvider(user)
            }
        }
    }
}
