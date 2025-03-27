import AWSMobileClientXCF
import SwiftUI

@available(iOS 17.0, *)
public struct AuthApp<SessionViewType: View, LoginViewType: View>: View {
    @ObservedObject private var authManager: AuthManager
    @StateObject private var appLifecycleObserver = AppLifecycleObserver()
    private let sessionViewProvider: (String) -> SessionViewType
    private let loginViewProvider: (LoginViewModel) -> LoginViewType

    public init(authManager: AuthManager,
                @ViewBuilder loginView: @escaping (LoginViewModel) -> LoginViewType = { viewModel in  LoginView(viewModel: viewModel)},
                @ViewBuilder sessionView: @escaping (String) -> SessionViewType) {
        self.authManager = authManager
        self.sessionViewProvider = sessionView
        self.loginViewProvider = loginView
    }

    public var body: some View {
        VStack {
            switch authManager.authState {
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
