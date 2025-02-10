//import Testing
//@testable import AuthLibrarySPM
//import AWSMobileClientXCF
//import XCTest

import Testing
@testable import AuthLibrarySPM
import AWSMobileClientXCF

@Suite
@MainActor
struct AuthenticationLibraryTests {
    var authManager: AuthManager
    var mockAuthService: MockAuthService

    init() {
        self.mockAuthService = MockAuthService()
        self.authManager = AuthManager(authService: mockAuthService)
    }

    @Test
    func testInitialState() {
        authManager.errorMessage = nil
        #expect(authManager.authState == .login)
        #expect(authManager.isLoggedIn == false)
        #expect(authManager.errorMessage == nil)
    }

    @available(iOS 16.0, *)
    @Test
    func testCheckUserStateLoggedIn() async throws {
        authManager.errorMessage = nil

        mockAuthService.checkUserStateResult = .success(.signedIn)
        authManager.checkUserState()

        try await Task.sleep(for: .milliseconds(200))

        #expect(authManager.authState == .session(user: "Session initiated"))
        #expect(authManager.isLoggedIn == true)
        #expect(authManager.errorMessage == nil)
    }

    @available(iOS 16.0, *)
    @Test
    func testCheckUserStateLoggedOut() async throws {
        authManager.errorMessage = nil
        
        mockAuthService.checkUserStateResult = .success(.signedOut)
        authManager.checkUserState()

        try await Task.sleep(for: .milliseconds(200))

        #expect(authManager.authState == .login)
        #expect(authManager.isLoggedIn == false)
        #expect(authManager.errorMessage == nil)
    }

    @available(iOS 16.0, *)
    @Test
    func testSignUpSuccess() async throws {
        let attributes = ["email": "testuser@mail.com", "name": "testuser@mail.com"]
        mockAuthService.signUpResult = .success(.unconfirmed)
        authManager.errorMessage = nil
        authManager.signUp(username: "testuser@mail.com", password: "Password1234_", attributes: attributes)

        try await Task.sleep(for: .milliseconds(100))
 
        #expect(authManager.authState == .confirmCode(username: "testuser@mail.com"))
        #expect(authManager.errorMessage == nil)
    }

    @available(iOS 16.0, *)
    @Test
    func testSignUpFailure() async throws {
        mockAuthService.signUpResult = .failure(.awsError(AWSMobileClientError.usernameExists(message: "Username already exists")))
        authManager.signUp(username: "testuser", password: "password", attributes: [:])

        try await Task.sleep(for: .milliseconds(100))

        #expect(authManager.errorMessage == "Username already exists")
    }

    @available(iOS 16.0, *)
    @Test
    func testConfirmSignUpSuccess() async throws {
        mockAuthService.confirmSignUpResult = .success(())
        authManager.errorMessage = nil
        authManager.confirmSignUp(username: "testuser", confirmationCode: "123456")

        try await Task.sleep(for: .milliseconds(100))

        #expect(authManager.authState == .login)
        #expect(authManager.errorMessage == nil)
    }

    @available(iOS 16.0, *)
    @Test
    func testConfirmSignUpFailure() async throws {
        mockAuthService.confirmSignUpResult = .failure(.awsError(AWSMobileClientError.invalidParameter(message: "Invalid code")))
        authManager.confirmSignUp(username: "testuser", confirmationCode: "123456")

        try await Task.sleep(for: .milliseconds(100))

        #expect(authManager.errorMessage == "Invalid code")
    }

    @available(iOS 16.0, *)
    @Test
    func testSignInSuccess() async throws {
        mockAuthService.signInResult = .success(.signedIn)
        authManager.errorMessage = nil
        mockAuthService.checkUserStateResult = .success(.signedIn)
        authManager.signIn(username: "testuser@mail.com", password: "Password123_")

        try await Task.sleep(for: .milliseconds(100))

        #expect(authManager.isLoggedIn == true)
        #expect(authManager.authState == .session(user: "Session initiated"))
        #expect(authManager.errorMessage == nil)
    }

    @available(iOS 16.0, *)
    @Test
    func testSignInFailure() async throws {
        mockAuthService.signInResult = .failure(.awsError(AWSMobileClientError.invalidParameter(message: "Invalid credentials")))
        authManager.signIn(username: "testuser", password: "password")

        try await Task.sleep(for: .milliseconds(100))

        #expect(authManager.errorMessage == "Invalid credentials")
    }

    @available(iOS 16.0, *)
    @Test
    func testSignOutSuccess() async throws {
        mockAuthService.signOutResult = .success(())
        authManager.errorMessage = nil
        authManager.signOut()

        try await Task.sleep(for: .milliseconds(100))
        #expect(authManager.isLoggedIn == false)
        #expect(authManager.authState == .login)
        #expect(authManager.errorMessage == nil)
    }

    @available(iOS 16.0, *)
    @Test
    func testSignOutFailure() async throws {
        mockAuthService.signOutResult = .failure(.awsError(AWSMobileClientError.badRequest(message: "Network error")))
        authManager.signOut()

        try await Task.sleep(for: .milliseconds(100))

        #expect(authManager.errorMessage == "Network error")
    }
}
