//
//  ConfirmationViewModel.swift
//  Library
//
//  Created by Dionicio Cruz Velázquez on 2/5/25.
//

import SwiftUI
import Combine

@available(iOS 13.0, *)
@MainActor
public final class ConfirmationViewModel: ObservableObject {
    // MARK: Public properties
    @Published public var confirmationCode: String = ""
    @Published public var username: String
    @Published public var showError: Bool = false
    @Published public var errorMessage: String? = nil
    @Published public var authState: AuthState = .login
    public let authVM: AuthViewModel
    public var authManager: AuthManager { authVM.authManager }

    // MARK: Private properties
    private var cancellables = Set<AnyCancellable>()

    // MARK: Initializers
    public init(authViewModel: AuthViewModel, username: String) {
        self.authVM = authViewModel
        self.username = username
        bindAuthVM()
    }

    public convenience init(authManager: AuthManager, username: String) {
        self.init(authViewModel: AuthViewModel(authManager: authManager), username: username)
    }

    // MARK: - Public methods

    public func confirmSignUp() {
        authManager.confirmSignUp(username: username, confirmationCode: confirmationCode)
    }

    public func clearErrorMessage() { authVM.clearErrorMessage() }

    @ViewBuilder
    public var errorTextView: some View { authVM.errorTextView }

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
