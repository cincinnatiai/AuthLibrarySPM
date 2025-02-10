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

    init() {
        self.mockAuthService = MockAuthService()
        self.authManager = AuthManager(authService: mockAuthService)
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

    @Test
    func testCheckUserState_SignedIn() {
        mockAuthService.checkUserStateResult = .success(.signedIn)
        authManager.checkUserState()
        
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

    @Test
    func testSignUp_Success() {
        mockAuthService.signUpResult = .success(.unconfirmed)
        
        authManager.signUp(username: "test@mail.com", password: "password", attributes: [:])
        
        #expect(authManager.authState == .confirmCode(username: "test@mail.com"))
    }

    @Test
    func testSignUp_Failure() {
        mockAuthService.signUpResult = .failure(.unknown)
        
        authManager.signUp(username: "test@mail.com", password: "password", attributes: [:])
        
        #expect(authManager.errorMessage != nil)
    }

    @Test
    func testConfirmSignUp_Success() {
        mockAuthService.confirmSignUpResult = .success(())
        
        authManager.confirmSignUp(username: "test@mail.com", confirmationCode: "123456")
        
        #expect(authManager.authState == .login)
    }

    @Test
    func testConfirmSignUp_Failure() {
        mockAuthService.confirmSignUpResult = .failure(.unknown)
        
        authManager.confirmSignUp(username: "test@mail.com", confirmationCode: "wrongCode")
        
        #expect(authManager.errorMessage != nil)
    }

    @Test
    func testSignIn_Success() {
        mockAuthService.signInResult = .success(.signedIn)
        
        authManager.signIn(username: "user@mail.com", password: "password")
        
        #expect(authManager.isLoggedIn == true)
    }

    @Test
    func testSignIn_Failure() {
        mockAuthService.signInResult = .failure(.unknown)
        
        authManager.signIn(username: "user@mail.com", password: "wrongpassword")
        
        #expect(authManager.errorMessage != nil)
    }

    @Test
    func testSignOut_Success() {
        mockAuthService.signOutResult = .success(())
        
        authManager.signOut()
        
        #expect(authManager.isLoggedIn == false)
        #expect(authManager.authState == .login)
    }

    @Test
    func testSignOut_Failure() {
        mockAuthService.signOutResult = .failure(.unknown)
        
        authManager.signOut()
        
        #expect(authManager.errorMessage != nil)
    }

    @Test
    func testHandleError_AWSError() {
        let awsError = AWSMobileClientError.unknown(message: "AWS error occurred")
        authManager.handleError(.awsError(awsError))
        
        #expect(authManager.errorMessage == awsError.stringMessage)
    }
}
