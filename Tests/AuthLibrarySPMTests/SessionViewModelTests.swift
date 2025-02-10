import Testing
@testable import AuthLibrarySPM

import Testing
import AuthLibrarySPM

@Suite
@MainActor
struct SessionViewModelTests {
    var authManager: MockAuthManager
    var viewModel: SessionViewModel

    init() {
        self.authManager = MockAuthManager()
        self.viewModel = SessionViewModel(authManager: authManager, user: "user@mail.com")
    }

    @Test
    func testInitialUser() {
        #expect(viewModel.user == "user@mail.com")
    }

    @Test
    func testLogout() {
        viewModel.logout()
        #expect(authManager.signOutCalled == true)
        #expect(authManager.authState == .login)
    }
}
