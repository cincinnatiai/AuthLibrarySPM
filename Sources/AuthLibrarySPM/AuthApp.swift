import AWSMobileClientXCF
import SwiftUI

@available(iOS 17.0, *)
public struct AuthApp<SessionViewType: View>: View {
    @EnvironmentObject var authManager: AuthManager
    private let sessionViewProvider: (String) -> SessionViewType

    public init(@ViewBuilder sessionView: @escaping (String) -> SessionViewType) {
        self.sessionViewProvider = sessionView
    }

    public var body: some View {
        VStack {
            switch authManager.authState {
            case .login:
                LoginView(viewModel: LoginViewModel(authManager: authManager))
            case .signUp:
                SignUpView(viewModel: SignUpViewModel(authManager: authManager))
            case .confirmCode(let username):
                ConfirmationView(viewModel: ConfirmationViewModel(authManager: authManager, username: username))
            case .session(let user):
                sessionViewProvider(user)
            }
        }
        .onAppear {
            addObservers()
        }
    }

    private func addObservers() {
        NotificationCenter.default.addObserver(forName: UIApplication.willResignActiveNotification, object: nil, queue: .main) { _ in
            UserDefaults.standard.set(true, forKey: "isAppRelaunch")
        }

        NotificationCenter.default.addObserver(forName: UIApplication.didBecomeActiveNotification, object: nil, queue: .main) { _ in
            UserDefaults.standard.set(false, forKey: "isAppRelaunch")
        }
    }
}

@available(iOS 17.0, *)
public extension AuthApp where SessionViewType == SessionView {
    init() {
        self.init { user in SessionView(viewModel: SessionViewModel(authManager: AuthManager(), user: user)) }
    }
}
