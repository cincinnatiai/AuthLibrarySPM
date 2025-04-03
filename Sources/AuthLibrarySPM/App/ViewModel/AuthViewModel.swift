//
//  AuthViewModel.swift
//  Library
//
//  Created by Dionicio Cruz Velázquez on 2/5/25.
//

import SwiftUI
import Combine

@available(iOS 14.0, *)
public class AuthViewModel: ObservableObject {

    @Published public var showError: Bool = false
    @Published public var authState: AuthState = .login
    @Published public var errorMessage: String? = nil

    public let authManager: AuthManager

    private var cancellables = Set<AnyCancellable>()

    public init(authManager: AuthManager) {
        self.authManager = authManager
        observeAuthManager()
    }

    public func clearErrorMessage() {
        authManager.clearErrorMessage()
        showError = false
    }

    private func observeAuthManager() {
        authManager.authStatePublisher
            .receive(on: DispatchQueue.main)
            .assign(to: &$authState)

        authManager.errorPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] error in
                self?.errorMessage = error
                self?.showError = error != nil
            }
            .store(in: &cancellables)
    }

    public func handleActionResult() {
        showError = self.errorMessage != nil
    }

    open func showSignUp() {
        authManager.showLogin()
    }

    open func showLogin() {
        authManager.showLogin()
    }

    open var errorTextView: some View {
        if let errorMessage = errorMessage {
            return AnyView(Text(errorMessage)
                .foregroundColor(.red))
        } else {
            return AnyView(EmptyView())
        }
    }
}

public enum AuthState: Equatable {
    case signUp
    case login
    case confirmCode(username: String)
    case session(user: String)
}
