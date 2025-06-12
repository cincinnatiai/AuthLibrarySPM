//
//  AuthManagerTests.swift
//  AuthLibrarySPM
//
//  Created by Dionicio Cruz Velázquez on 2/7/25.
//

import Testing
import AuthLibrarySPM
import AWSMobileClientXCF

@Suite
@MainActor
struct AuthManagerTests {
    var authManager: AuthManager
    var mockAuthService: MockAuthService
    var mockTokenHandler: MockTokenHandler

    init() {
        self.mockAuthService = MockAuthService()
        self.authManager = AuthManager(authService: mockAuthService)
        self.mockTokenHandler = MockTokenHandler()
    }

    @Test
    func testShowSignUp() {
        authManager.showSignUp()
        #expect(authManager.authStateSubject.value == .signUp)
    }

    @Test
    func testShowLogin() {
        authManager.showLogin()
        #expect(authManager.authStateSubject.value == .login)
    }

    @available(iOS 16.0, *)
    @Test
    func testCheckUserState_SignedIn() async throws {
        mockAuthService.setCheckUserStateResult(.success(.signedIn))
        authManager.checkUserState()
        try await Task.sleep(for: .milliseconds(200))
        #expect(authManager.isLoggedIn == true)
        #expect(authManager.authStateSubject.value == .session(user: "Session initiated"))
    }

    @Test
    func testCheckUserState_NotSignedIn() {
        mockAuthService.setCheckUserStateResult(.success(.signedOut))
        authManager.checkUserState()
        #expect(authManager.isLoggedIn == false)
        #expect(authManager.authStateSubject.value == .login)
    }

    @available(iOS 16.0, *)
    @Test
    func testSignUp_Success() async throws {
        mockAuthService.setSignUpResult(.success(.unconfirmed))
        authManager.signUp(username: "test@mail.com", password: "password", attributes: [:])
        try await Task.sleep(for: .milliseconds(200))
        #expect(authManager.authStateSubject.value == .confirmCode(username: "test@mail.com"))
    }

    @available(iOS 16.0, *)
    @Test
    func testSignUp_Failure() async throws {
        mockAuthService.setSignUpResult(.failure(.awsError(.unknown(message: "Unknown"))))
        authManager.signUp(username: "test@mail.com", password: "password", attributes: [:])
        try await Task.sleep(for: .milliseconds(200))
        #expect(authManager.errorSubject != nil)
    }

    @Test
    func testConfirmSignUp_Success() {
        mockAuthService.setConfirmSignUpResult(.success(()))
        authManager.confirmSignUp(username: "test@mail.com", confirmationCode: "123456")
        #expect(authManager.authStateSubject.value == .login)
    }

    @available(iOS 16.0, *)
    @Test
    func testConfirmSignUp_Failure() async throws {
        mockAuthService.setConfirmSignUpResult(.failure(.unknown))
        authManager.confirmSignUp(username: "test@mail.com", confirmationCode: "wrongCode")
        try await Task.sleep(for: .milliseconds(200))
        #expect(authManager.errorSubject != nil)
    }

    @available(iOS 16.0, *)
    @Test
    func testSignIn_Success() async throws {
        mockAuthService.setSignInResult(.success(.signedIn))
        mockAuthService.setCheckUserStateResult(.success(.signedIn))
        authManager.signIn(username: "user@mail.com", password: "password")
        try await Task.sleep(for: .milliseconds(200))
        #expect(authManager.isLoggedIn == true)
    }

    @available(iOS 16.0, *)
    @Test
    func testSignIn_Failure() async throws {
        mockAuthService.setSignInResult(.failure(.unknown))
        authManager.signIn(username: "user@mail.com", password: "wrongpassword")
        try await Task.sleep(for: .milliseconds(200))
        #expect(authManager.errorSubject != nil)
    }

    @Test
    func testSignOut_Success() {
        mockAuthService.setSignOutResult(.success(()))
        authManager.signOut()
        #expect(authManager.isLoggedIn == false)
        #expect(authManager.authStateSubject.value == .login)
    }

    @available(iOS 16.0, *)
    @Test
    func testSignOut_Failure() async throws {
        mockAuthService.setSignOutResult(.failure(.unknown))
        authManager.signOut()
        try await Task.sleep(for: .milliseconds(200))
        #expect(authManager.errorSubject != nil)
    }

    @available(iOS 16.0, *)
    @Test
    func testHandleError_AWSError() async throws {
        var receivedError: String?
        let cancellable = authManager.errorPublisher
            .sink { receivedError = $0 }

        let awsError = AWSMobileClientError.unknown(message: "AWS error occurred")
        authManager.handleError(.awsError(awsError))

        #expect(receivedError == awsError.stringMessage)
        _ = cancellable
    }

    @available(iOS 16.0, *)
    @Test
    func testManageToken_Success() async throws {
        let expectedIdToken = "id-123"
        let expectedAccessToken = "access-123"
        let expectedRefreshToken = "refresh-123"

        mockAuthService.setSignInResult(.success(.signedIn))
        mockAuthService.setGetTokenResult(.success(expectedIdToken))
        mockAuthService.setGetAccessTokenResult(.success(expectedAccessToken))
        mockAuthService.setGetRefreshTokenResult(.success(expectedRefreshToken))

        authManager.setTokenProtocol(mockTokenHandler)
        authManager.signIn(username: "Test", password: "Test")
        try await Task.sleep(for: .milliseconds(200))

        #expect(mockTokenHandler.idToken == expectedIdToken)
        #expect(mockTokenHandler.accessToken == expectedAccessToken)
        #expect(mockTokenHandler.refreshToken == expectedRefreshToken)
    }

    @available(iOS 16.0, *)
    @Test
    func testManageToken_Failure() async throws {
        mockAuthService.setSignInResult(.success(.signedIn))
        mockAuthService.setGetTokenResult(.failure(.unknown))
        authManager.setTokenProtocol(mockTokenHandler)
        authManager.signIn(username: "Test", password: "Test")
        try await Task.sleep(for: .milliseconds(200))

        #expect(mockTokenHandler.idToken == nil)
    }
}
