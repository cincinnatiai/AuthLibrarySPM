
import SwiftUI

@available(iOS 17.0, *)
public struct AuthApp<SessionViewType: View, LoginViewType: View>: View {

    // MARK: Private properties
    @ObservedObject private var authManager: AuthManager
    @ObservedObject private var authViewModel: AuthViewModel
    @StateObject private var appLifecycleObserver = AppLifecycleObserver()

    private let sessionViewProvider: (String) -> SessionViewType
    private let loginViewProvider: (LoginViewModel) -> LoginViewType

    // MARK: - Initializer
    public init(
        authManager: AuthManager,
        authViewModel: AuthViewModel,
        @ViewBuilder loginView: @escaping (LoginViewModel) -> LoginViewType = { vm in
            LoginView(viewModel: vm)
        },
        @ViewBuilder sessionView: @escaping (String) -> SessionViewType
    ) {
        self.authManager = authManager
        self.authViewModel = authViewModel
        self.sessionViewProvider = sessionView
        self.loginViewProvider = loginView
    }

    // MARK: - Body builder
    public var body: some View {
        VStack {
            switch authViewModel.authState {

            case .login:
                let vm = LoginViewModel(authViewModel: authViewModel)
                loginViewProvider(vm)

            case .signUp:
                let vm = SignUpViewModel(authViewModel: authViewModel)
                SignUpView(viewModel: vm)

            case .confirmCode(let username):
                let vm = ConfirmationViewModel(authViewModel: authViewModel, username: username)
                ConfirmationView(viewModel: vm)

            case .session(let user):
                sessionViewProvider(user)
            }
        }
    }
}

