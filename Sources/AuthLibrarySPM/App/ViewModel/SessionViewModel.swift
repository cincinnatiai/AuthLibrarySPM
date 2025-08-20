//
//  SessionViewModel.swift
//  Library
//
//  Created by Dionicio Cruz Velázquez on 2/5/25.
//

import SwiftUI
import Combine

@available(iOS 13.0, *)
@MainActor
public final class SessionViewModel: ObservableObject {
    // MARK: Public properties
    @Published public var user: String
    @Published public var showError: Bool = false
    @Published public var errorMessage: String? = nil
    @Published public var authState: AuthState = .login
    public let authVM: AuthViewModel
    public var authManager: AuthManager { authVM.authManager }

    // MARK: Private properties
    private var cancellables = Set<AnyCancellable>()

    // MARK: Initializer
    public init(authViewModel: AuthViewModel, user: String) {
        self.authVM = authViewModel
        self.user = user
        bindAuthVM()
    }

    public convenience init(authManager: AuthManager, user: String) {
        let authVM = AuthViewModel(authManager: authManager)
        self.init(authViewModel: authVM, user: user)
    }

    // MARK: - Public methods

    public func logout() {
        authManager.signOut()
    }

    public func clearErrorMessage() {
        authVM.clearErrorMessage()
    }

    @ViewBuilder
    public var errorTextView: some View {
        authVM.errorTextView
    }

    // MARK: - Private methods

    private func bindAuthVM() {
        authVM.$showError
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in self?.showError = $0 }
            .store(in: &cancellables)

        authVM.$errorMessage
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in self?.errorMessage = $0 }
            .store(in: &cancellables)

        authVM.$authState
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in self?.authState = $0 }
            .store(in: &cancellables)
    }
}

