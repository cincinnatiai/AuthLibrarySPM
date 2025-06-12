//
//  AuthenticationLibraryTests.swift
//  AuthLibrarySPM
//
//  Created by Dionicio Cruz Velázquez on 2/7/25.
//

import Testing
@testable import AuthLibrarySPM
import AWSMobileClientXCF

@Suite
@MainActor
struct AuthenticationLibraryTests {
    var authManager: AuthManager
    var mockAuthService: MockAuthService
    var mockTokenHandler: MockTokenHandler

    init() {
        self.mockAuthService = MockAuthService()
        self.authManager = AuthManager(authService: mockAuthService)
        self.mockTokenHandler = MockTokenHandler()
    }

    @Test
    func testInitialState() {
        var receivedError: String?

        let cancellable = authManager.errorPublisher
            .sink { receivedError = $0 }

        authManager.errorSubject.send(nil)

        #expect(authManager.authStateSubject.value == .login)
        #expect(authManager.isLoggedIn == false)
        #expect(receivedError == nil)

        _ = cancellable
    }

    @available(iOS 16.0, *)
    @Test
    func testCheckUserStateLoggedIn() async throws {
        var receivedError: String?

        let cancellable = authManager.errorPublisher
            .sink { receivedError = $0 }

        mockAuthService.setCheckUserStateResult(.success(.signedIn))
        authManager.checkUserState()

        try await Task.sleep(for: .milliseconds(200))

        #expect(authManager.authStateSubject.value == .session(user: "Session initiated"))
        #expect(authManager.isLoggedIn == true)
        #expect(receivedError == nil)

        _ = cancellable
    }

    @available(iOS 16.0, *)
    @Test
    func testCheckUserStateLoggedOut() async throws {
        var receivedError: String?

        let cancellable = authManager.errorPublisher
            .sink { receivedError = $0 }

        mockAuthService.setCheckUserStateResult(.success(.signedOut))
        authManager.checkUserState()

        try await Task.sleep(for: .milliseconds(200))

        #expect(authManager.authStateSubject.value == .login)
        #expect(authManager.isLoggedIn == false)
        #expect(receivedError == nil)

        _ = cancellable
    }

    @available(iOS 16.0, *)
    @Test
    func testSignUpSuccess() async throws {
        var receivedError: String?

        let cancellable = authManager.errorPublisher
            .sink { receivedError = $0 }

        let attributes = ["email": "testuser@mail.com", "name": "testuser@mail.com"]

        mockAuthService.setSignUpResult(.success(.unconfirmed))
        authManager.signUp(username: "testuser@mail.com", password: "Password1234_", attributes: attributes)

        try await Task.sleep(for: .milliseconds(100))

        #expect(authManager.authStateSubject.value == .confirmCode(username: "testuser@mail.com"))
        #expect(receivedError == nil)

        _ = cancellable
    }

    @available(iOS 16.0, *)
    @Test
    func testSignUpFailure() async throws {
        var receivedError: String?

        let cancellable = authManager.errorPublisher
            .sink { receivedError = $0 }

        mockAuthService.setSignUpResult(.failure(.awsError(AWSMobileClientError.usernameExists(message: "Username already exists"))))
        authManager.signUp(username: "testuser", password: "password", attributes: [:])

        try await Task.sleep(for: .milliseconds(100))

        #expect(receivedError == "Username already exists")

        _ = cancellable
    }

    @available(iOS 16.0, *)
    @Test
    func testConfirmSignUpSuccess() async throws {
        var receivedError: String?

        let cancellable = authManager.errorPublisher
            .sink { receivedError = $0 }

        mockAuthService.setConfirmSignUpResult(.success(()))
        authManager.confirmSignUp(username: "testuser", confirmationCode: "123456")

        try await Task.sleep(for: .milliseconds(100))

        #expect(authManager.authStateSubject.value == .login)
        #expect(receivedError == nil)

        _ = cancellable
    }

    @available(iOS 16.0, *)
    @Test
    func testConfirmSignUpFailure() async throws {
        var receivedError: String?

        let cancellable = authManager.errorPublisher
            .sink { receivedError = $0 }

        mockAuthService.setConfirmSignUpResult(.failure(.awsError(AWSMobileClientError.invalidParameter(message: "Invalid code"))))
        authManager.confirmSignUp(username: "testuser", confirmationCode: "123456")

        try await Task.sleep(for: .milliseconds(100))

        #expect(receivedError == "Invalid code")

        _ = cancellable
    }

    @available(iOS 16.0, *)
    @Test
    func testSignInSuccess() async throws {
        var receivedError: String?

        let cancellable = authManager.errorPublisher
            .sink { receivedError = $0 }

        mockAuthService.setSignInResult(.success(.signedIn))
        mockAuthService.setCheckUserStateResult(.success(.signedIn))
        mockAuthService.setGetTokenResult(.success("Mock-Token"))

        authManager.setTokenProtocol(mockTokenHandler)
        authManager.signIn(username: "testuser@mail.com", password: "password123_")

        try await Task.sleep(for: .milliseconds(100))

        #expect(authManager.isLoggedIn == true)
        #expect(authManager.authStateSubject.value == .session(user: "Session initiated"))
        #expect(receivedError == nil)

        _ = cancellable
    }

    @available(iOS 16.0, *)
    @Test
    func testSignInFailure() async throws {
        var receivedError: String?

        let cancellable = authManager.errorPublisher
            .sink { receivedError = $0 }

        mockAuthService.setSignInResult(.failure(.awsError(AWSMobileClientError.invalidParameter(message: "Invalid credentials"))))
        authManager.signIn(username: "testuser", password: "password")

        try await Task.sleep(for: .milliseconds(100))

        #expect(receivedError == "Invalid credentials")

        _ = cancellable
    }

    @available(iOS 16.0, *)
    @Test
    func testSignOutSuccess() async throws {
        var receivedError: String?

        let cancellable = authManager.errorPublisher
            .sink { receivedError = $0 }

        mockAuthService.setSignOutResult(.success(()))
        authManager.signOut()

        try await Task.sleep(for: .milliseconds(100))

        #expect(authManager.isLoggedIn == false)
        #expect(authManager.authStateSubject.value == .login)
        #expect(receivedError == nil)

        _ = cancellable
    }

    @available(iOS 16.0, *)
    @Test
    func testSignOutFailure() async throws {
        var receivedError: String?

        let cancellable = authManager.errorPublisher
            .sink { receivedError = $0 }

        mockAuthService.setSignOutResult(.failure(.awsError(AWSMobileClientError.badRequest(message: "Network error"))))
        authManager.signOut()

        try await Task.sleep(for: .milliseconds(100))

        #expect(receivedError == "Network error")

        _ = cancellable
    }
}
