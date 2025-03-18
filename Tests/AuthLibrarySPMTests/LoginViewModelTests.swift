//
//  LoginViewModelTests2.swift
//  AuthenticationLibrary_Tests
//
//  Created by Dionicio Cruz Velázquez on 2/6/25.
//  Copyright © 2025 CocoaPods. All rights reserved.
//

import Testing
@testable import AuthLibrarySPM
import Foundation

@Suite
@MainActor
struct LoginViewModelTests {
    var authManager: MockAuthManager
    var keychain: MockKeychainValues
    var preferences: MockFaceIDPreferences
    var faceIDAuthenticator: MockFaceIDAuthenticator
    var viewModel: LoginViewModel

    init() {
        self.authManager = MockAuthManager()
        self.keychain = MockKeychainValues()
        self.preferences = MockFaceIDPreferences()
        self.faceIDAuthenticator = MockFaceIDAuthenticator()

        self.viewModel = LoginViewModel(authManager: authManager, keychain: keychain, preferences: preferences, faceIDAuthenticator: faceIDAuthenticator)
    }

    @Test
    func testLoginSuccess() async {
        // Given
        viewModel.email = "example@mail.com"
        viewModel.password = "password123_"

        // When
        await viewModel.login()

        // Then
        #expect(authManager.signInCalled == true)
        #expect(authManager.authState == .session(user: "example@mail.com"))
        #expect(viewModel.showError == false)
    }

    @Test
    func testLoginFail() async {
        // Given
        viewModel.email = "Example@example.com"
        viewModel.password = "password123/"

        // When
        await viewModel.login()

        // Then
        #expect(authManager.signInCalled == true)
        #expect(viewModel.showError == true)
        #expect(authManager.authState == .login)
        #expect(authManager.errorMessage == "Invalid credentials")
    }

    @Test
    func testAutoLoginOnAppRelaunch() async {
        // Given
        preferences.isAppRelaunch = true
        preferences.isFaceIDEnabled = true
        viewModel.isFaceIDEnabled = true
        faceIDAuthenticator.shouldSucceed = true
        keychain.set("example@mail.com", key: "email")
        keychain.set("password123_", key: "password")

        // When
        await viewModel.tryAutoLogin()

        // Then
        #expect(authManager.signInCalled == true)
        #expect(authManager.authState == .session(user: "example@mail.com"))
        #expect(viewModel.showError == false)
    }

    @Test
    func testToggleFaceIDEnabled() async {
        // When
        await viewModel.toggleFaceID(true)

        // Then
        #expect(preferences.isFaceIDEnabled == true)
        #expect(preferences.hasLoggedOut == false)
    }

    @Test
    func testToggleFaceIDDisabled() async {
        // When
        await viewModel.toggleFaceID(false)

        // Then
        #expect(preferences.isFaceIDEnabled == false)
    }

    @Test
    func testAuthenticateAndLogin_FaceIDFails() async {
        // Given
        faceIDAuthenticator.simulateError = .authenticationFailed("Face ID permission denied")

        // When
        await viewModel.authenticateAndLogin()

        // Then
        #expect(viewModel.authenticationError == "Face ID authentication failed: Face ID permission denied")
        #expect(authManager.signInCalled == false)
    }

    @Test
    func testAuthenticateAndLogin_NoStoredCredentials() async {
        // Given
        faceIDAuthenticator.shouldSucceed = true
        keychain.remove(key: "email")
        keychain.remove(key: "password")

        // When
        await viewModel.authenticateAndLogin()

        // Then
        #expect(viewModel.authenticationError == "No saved credentials found.")
        #expect(authManager.signInCalled == false)
    }

    @Test
    func testToggleFaceID_UserDisables() async {
        // Given
        faceIDAuthenticator.shouldSucceed = false

        // When
        await viewModel.toggleFaceID(true)

        // Then
        #expect(viewModel.isFaceIDEnabled == false)
    }

    @Test
    func testToggleFaceID_FaceIDThrowsError() async {
        // Given
        faceIDAuthenticator.shouldSucceed = true
        faceIDAuthenticator.simulateError = FaceIdError.biometryLockout

        // When
        await viewModel.toggleFaceID(true)

        // Then
        #expect(viewModel.authenticationError == "Too many failed attempts. Try again later or use a password.")
        #expect(viewModel.isFaceIDEnabled == false)
    }

    @Test
    func testToggleFaceID_UnexpectedError() async {
        // Given
        faceIDAuthenticator.shouldSucceed = true
        faceIDAuthenticator.simulateUnkownError = NSError(domain: "TestError", code: -1, userInfo: nil)

        // When
        await viewModel.toggleFaceID(true)

        // Then
        #expect(viewModel.authenticationError == "Face ID permission denied")
        #expect(viewModel.isFaceIDEnabled == false)
    }


    @Test
    func testShowSignUp() {
        // When
        viewModel.signUp()

        // Then
        #expect(authManager.showSignUpCalled == true)
    }
}
