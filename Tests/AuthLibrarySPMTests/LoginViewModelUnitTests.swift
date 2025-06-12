import Testing
@testable import AuthLibrarySPM
import Combine

@MainActor
struct LoginViewModelUnitTests {

    var mockTokenHandler: MockTokenHandler
    var keychain: KeychainProtocol
    var authService: MockAuthService
    var authManager: AuthManager
    var viewModel: LoginViewModel

    init() {
        mockTokenHandler = MockTokenHandler()
        keychain = MockKeychainValues()

        authService = MockAuthService()

        authManager = AuthManager(authService: authService)
        authManager.setTokenProtocol(mockTokenHandler)

        viewModel = LoginViewModel(authManager: authManager, keychain: keychain, preferences: MockFaceIDPreferences())
    }

    @available(iOS 16.0, *)
    @Test
    func testSuccessfulLogin() async throws {
        // Given
        viewModel.email = "your-email@mail.com"
        viewModel.password = "your-password"
        viewModel.isFaceIDEnabled = false

        authService.setSignInResult(.success(.signedIn))
        authService.setCheckUserStateResult(.success(.signedIn))

        var receivedState: AuthState? = nil
        let cancellable = authManager.authStatePublisher
            .sink { receivedState = $0 }

        // When
        authManager.signIn(username: viewModel.email, password: viewModel.password)
        try await Task.sleep(for: .milliseconds(200))

        // Then
        if case .session(let user)? = receivedState {
            #expect(user == "Session initiated")
            #expect(authManager.isLoggedIn == true)
        } else {
            #expect(Bool(false), "Unexpected auth state: \(String(describing: receivedState))")
        }

        _ = cancellable
    }
}
