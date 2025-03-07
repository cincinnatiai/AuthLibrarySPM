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
        #expect(authManager.authState == .signUp)
    }

    @Test
    func testShowLogin() {
        authManager.showLogin()
        #expect(authManager.authState == .login)
    }

    @available(iOS 16.0, *)
    @Test
    func testCheckUserState_SignedIn() async throws {
        mockAuthService.checkUserStateResult = .success(.signedIn)
        authManager.checkUserState()

        try await Task.sleep(for: .milliseconds(200))

        #expect(authManager.isLoggedIn == true)
        #expect(authManager.authState == .session(user: "Session initiated"))
    }


    @Test
    func testCheckUserState_NotSignedIn() {
        mockAuthService.checkUserStateResult = .success(.signedOut)
        authManager.checkUserState()
        
        #expect(authManager.isLoggedIn == false)
        #expect(authManager.authState == .login)
    }

    @available(iOS 16.0, *)
    @Test
    func testSignUp_Success() async throws {
        mockAuthService.signUpResult = .success(.unconfirmed)
        
        authManager.signUp(username: "test@mail.com", password: "password", attributes: [:])
        
        try await Task.sleep(for: .milliseconds(200))
        
        #expect(authManager.authState == .confirmCode(username: "test@mail.com"))
    }

    @available(iOS 16.0, *)
    @Test
    func testSignUp_Failure() async throws {
        mockAuthService.signUpResult = .failure(.unknown)
        
        authManager.signUp(username: "test@mail.com", password: "password", attributes: [:])
        try await Task.sleep(for: .milliseconds(200))
        #expect(authManager.errorMessage != nil)
    }

    @Test
    func testConfirmSignUp_Success() {
        mockAuthService.confirmSignUpResult = .success(())
        
        authManager.confirmSignUp(username: "test@mail.com", confirmationCode: "123456")
        
        #expect(authManager.authState == .login)
    }

    @available(iOS 16.0, *)
    @Test
    func testConfirmSignUp_Failure() async throws {
        mockAuthService.confirmSignUpResult = .failure(.unknown)
        
        authManager.confirmSignUp(username: "test@mail.com", confirmationCode: "wrongCode")
        try await Task.sleep(for: .milliseconds(200))
        
        #expect(authManager.errorMessage != nil)
    }

    @available(iOS 16.0, *)
    @Test
    func testSignIn_Success() async throws {
        mockAuthService.signInResult = .success(.signedIn)
        mockAuthService.checkUserStateResult = .success(.signedIn)

        authManager.signIn(username: "user@mail.com", password: "password")
        
        try await Task.sleep(for: .milliseconds(200))
        
        #expect(authManager.isLoggedIn == true)
    }


    @available(iOS 16.0, *)
    @Test
    func testSignIn_Failure() async throws {
        mockAuthService.signInResult = .failure(.unknown)
        
        authManager.signIn(username: "user@mail.com", password: "wrongpassword")
        try await Task.sleep(for: .milliseconds(200))
        
        #expect(authManager.errorMessage != nil)
    }

    @Test
    func testSignOut_Success() {
        mockAuthService.signOutResult = .success(())
        
        authManager.signOut()
        
        #expect(authManager.isLoggedIn == false)
        #expect(authManager.authState == .login)
    }

    @available(iOS 16.0, *)
    @Test
    func testSignOut_Failure() async throws {
        mockAuthService.signOutResult = .failure(.unknown)
        
        authManager.signOut()
        try await Task.sleep(for: .milliseconds(200))
        
        #expect(authManager.errorMessage != nil)
    }

    @available(iOS 16.0, *)
    @Test
    func testHandleError_AWSError() async throws {
        let awsError = AWSMobileClientError.unknown(message: "AWS error occurred")
        authManager.handleError(.awsError(awsError))
        try await Task.sleep(for: .milliseconds(200))
        
        #expect(authManager.errorMessage == awsError.stringMessage)
    }

    @available(iOS 16.0, *)
    @Test
    func testManageToken_Success() async throws {
        let expectedToken = "expectedToken"
        mockAuthService.signInResult = .success(.signedIn)
        mockAuthService.getTokenResult = .success(expectedToken)
        authManager.setTokenProtocol(mockTokenHandler)
        authManager.signIn(username: "test", password: "test")
        try await Task.sleep(for: .milliseconds(200))
        #expect(mockTokenHandler.token == expectedToken)
    }

    @available(iOS 16.0, *)
    @Test
    func testManageToken_Failure() async throws {
        mockAuthService.signInResult = .success(.signedIn)
        mockAuthService.getTokenResult = .failure(.unknown)
        authManager.setTokenProtocol(mockTokenHandler)
        authManager.signIn(username: "Test", password: "Test")
        try await Task.sleep(for: .milliseconds(200))
        #expect(mockTokenHandler.token == nil)

    }
}
