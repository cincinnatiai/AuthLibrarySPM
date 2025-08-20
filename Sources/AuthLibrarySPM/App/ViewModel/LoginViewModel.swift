//
//  LoginViewModel.swift
//  Library
//
//  Created by Dionicio Cruz Velázquez on 2/5/25.
//

import SwiftUI
import Combine

@available(iOS 13.0, *)
@MainActor
public final class LoginViewModel: ObservableObject {
    // MARK: Public properties
    @Published public var email: String = ""
    @Published public var password: String = ""
    @Published public var isFaceIDEnabled: Bool = false

    // MARK: Private properties
    private let authVM: AuthViewModel
    private let authManager: AuthManager
    private var cancellables = Set<AnyCancellable>()

    // MARK: Initializers
    public init(authViewModel: AuthViewModel) {
        self.authVM = authViewModel
        self.authManager = authViewModel.authManager
    }

    // MARK: Public methods
    public func clearErrorMessage() { authVM.clearErrorMessage() }
    public func signUp()            { authVM.showSignUp() }
    public var errorTextView: some View { authVM.errorTextView }

    public func toggleFaceID(_ enabled: Bool) async {
        self.isFaceIDEnabled = enabled
    }

    public func login() async {
        let u = email.trimmingCharacters(in: .whitespacesAndNewlines)
        let p = password
        await withCheckedContinuation { (cont: CheckedContinuation<Void, Never>) in
            authManager.signIn(username: u, password: p)
            cont.resume()
        }
    }

    public func tryAutoLogin() {
        // TODO: Implement logic
    }
}
