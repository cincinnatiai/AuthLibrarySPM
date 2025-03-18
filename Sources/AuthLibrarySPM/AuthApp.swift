import AWSMobileClientXCF
import SwiftUI

@available(iOS 17.0, *)
public struct AuthApp<SessionViewType: View>: View {
    @ObservedObject private var authManager: AuthManager
    @StateObject private var appLifecycleObserver = AppLifecycleObserver()
    private let sessionViewProvider: (String) -> SessionViewType

    public init(authManager: AuthManager, @ViewBuilder sessionView: @escaping (String) -> SessionViewType) {
        self.authManager = authManager
        self.sessionViewProvider = sessionView
    }

    public var body: some View {
        VStack {
            switch authManager.authState {
            case .login:
                LoginView(viewModel: LoginViewModel(authManager: authManager, preferences: FaceIDPreferencesManager()))
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
