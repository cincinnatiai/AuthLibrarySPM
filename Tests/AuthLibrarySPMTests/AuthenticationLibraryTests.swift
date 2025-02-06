import Testing
@testable import AuthLibrarySPM
import AWSMobileClientXCF
import XCTest

@available(iOS 13.0, *)
final class AuthenticationLibraryTests: XCTestCase {
    var authManager: AuthManager!
    var mockAuthService: MockAuthService!
    
    override func setUp() {
        super.setUp()
        mockAuthService = MockAuthService()
        authManager = AuthManager(authService: mockAuthService)
    }
    
    override func tearDown() {
        authManager = nil
        mockAuthService = nil
        super.tearDown()
    }
    
    func testInitialState() {
        XCTAssertEqual(authManager.authState, .login)
        XCTAssertFalse(authManager.isLoggedIn)
        XCTAssertNil(authManager.errorMessage)
    }

    @MainActor
    func testCheckUserStateLoggedIn() {
        let expectation = self.expectation(description: "Check user state should set the correct auth state")
        
        mockAuthService.checkUserStateResult = .success(.signedIn)
        authManager.checkUserState()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            XCTAssertEqual(self.authManager.authState, .session(user: "Session initiated"))
            XCTAssertTrue(self.authManager.isLoggedIn)
            XCTAssertNil(self.authManager.errorMessage)
            
            expectation.fulfill()
        }
        waitForExpectations(timeout: 2, handler: nil)
    }
    
    @MainActor
    func testCheckUserStateLoggedOut() {
        mockAuthService.checkUserStateResult = .success(.signedOut)
        authManager.checkUserState()
        
        XCTAssertEqual(authManager.authState, .login)
        XCTAssertFalse(authManager.isLoggedIn)
        XCTAssertNil(authManager.errorMessage)
    }
    
    @MainActor
    func testSignUpSuccess() {
        let expectation = self.expectation(description: "Sign up should succeed and update auth state")
        let attributes = ["email": "testuser@mail.com", "name": "testuser@mail.com"]
        
        mockAuthService.signUpResult = .success(SignUpConfirmationState.unconfirmed)
        authManager.signUp(username: "testuser@mail.com", password: "Password1234_", attributes: attributes)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            XCTAssertEqual(self.authManager.authState, .confirmCode(username: "testuser@mail.com"))
            XCTAssertNil(self.authManager.errorMessage)
            
            expectation.fulfill()
        }
        waitForExpectations(timeout: 2, handler: nil)
    }

    @MainActor
    func testSignUpFailure() {
        let expectation = self.expectation(description: "Sign up should fail with an error")
        
        mockAuthService.signUpResult = .failure(.awsError(AWSMobileClientError.usernameExists(message: "Username already exists")))
        authManager.signUp(username: "testuser", password: "password", attributes: [:])
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            XCTAssertEqual(self.authManager.errorMessage, "Username already exists")
            expectation.fulfill()
        }
        waitForExpectations(timeout: 2, handler: nil)
    }
    
    @MainActor
    func testConfirmSignUpSuccess() {
        mockAuthService.confirmSignUpResult = .success(())
        authManager.confirmSignUp(username: "testuser", confirmationCode: "123456")
        
        XCTAssertEqual(authManager.authState, .login)
        XCTAssertNil(authManager.errorMessage)
    }
    
    @MainActor
    func testConfirmSignUpFailure() {
        let expectation = self.expectation(description: "Confirm sign-up should fail with an error")
        
        mockAuthService.confirmSignUpResult = .failure(.awsError(AWSMobileClientError.invalidParameter(message: "Invalid code")))
        authManager.confirmSignUp(username: "testuser", confirmationCode: "123456")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            XCTAssertEqual(self.authManager.errorMessage, "Invalid code")
            expectation.fulfill()
        }
        waitForExpectations(timeout: 2, handler: nil)
    }
    
    @MainActor
    func testSignInSuccess() {
        let expectation = self.expectation(description: "Sign in completes")
        
        mockAuthService.signInResult = .success(.signedIn)
        mockAuthService.checkUserStateResult = .success(.signedIn)
        authManager.signIn(username: "testuser@mail.com", password: "Password123_")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            expectation.fulfill()
        }
        waitForExpectations(timeout: 2, handler: nil)
        
        XCTAssertTrue(authManager.isLoggedIn, "User should be logged in.")
        XCTAssertEqual(authManager.authState, .session(user: "Session initiated"), "Auth state should be session.")
        XCTAssertNil(authManager.errorMessage, "There should be no error message.")
    }
    
    @MainActor
    func testSignInFailure() {
        let expectation = self.expectation(description: "Sign in should fail with an error")
        
        mockAuthService.signInResult = .failure(.awsError(AWSMobileClientError.invalidParameter(message: "Invalid credentials")))
        authManager.signIn(username: "testuser", password: "password")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            XCTAssertEqual(self.authManager.errorMessage, "Invalid credentials")
            expectation.fulfill()
        }
        waitForExpectations(timeout: 2, handler: nil)
    }
    
    @MainActor
    func testSignOutSuccess() {
        mockAuthService.signOutResult = .success(())
        authManager.signOut()
        
        XCTAssertFalse(authManager.isLoggedIn)
        XCTAssertEqual(authManager.authState, .login)
        XCTAssertNil(authManager.errorMessage)
    }
    
    @MainActor
    func testSignOutFailure() {
        let expectation = self.expectation(description: "Sign out should fail with an error")
        
        mockAuthService.signOutResult = .failure(.awsError(AWSMobileClientError.badRequest(message: "Network error")))
        authManager.signOut()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            XCTAssertEqual(self.authManager.errorMessage, "Network error")
            expectation.fulfill()
        }
        waitForExpectations(timeout: 2, handler: nil)
    }
}
