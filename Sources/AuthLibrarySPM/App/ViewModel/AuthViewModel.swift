//
//  AuthViewModel.swift
//  Library
//
//  Created by Dionicio Cruz Velázquez on 2/5/25.
//

import SwiftUI
import Combine

@available(iOS 13.0, *)
@MainActor
public final class AuthViewModel: ObservableObject {
    // MARK: Public properties
    @Published public var showError: Bool = false
    @Published public var authState: AuthState = .login
    @Published public var errorMessage: String? = nil
    public let authManager: AuthManager

    // MARK: Private properties
    private var cancellables = Set<AnyCancellable>()

    // MARK: Initializer
    public init(authManager: AuthManager) {
        self.authManager = authManager
        observeAuthManager()
    }

    // MARK: Public methods
    public func clearErrorMessage() {
        authManager.clearErrorMessage()
        showError = false
    }

    public func handleActionResult() {
        showError = (errorMessage != nil)
    }

    public func showSignUp() { authManager.showSignUp() }
    public func showLogin()  { authManager.showLogin()  }

    @ViewBuilder
    public var errorTextView: some View {
        if let errorMessage {
            Text(errorMessage).foregroundColor(.red)
        } else {
            EmptyView()
        }
    }

    // MARK: Private properties
    private func observeAuthManager() {
        authManager.authStatePublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] s in self?.authState = s }
            .store(in: &cancellables)

        authManager.errorPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] e in
                self?.errorMessage = e
                self?.showError = (e != nil)
            }
            .store(in: &cancellables)
    }
}

public enum AuthState: Equatable {
    case signUp
    case login
    case confirmCode(username: String)
    case session(user: String)
}
