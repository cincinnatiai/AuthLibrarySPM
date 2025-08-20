//
//  File.swift
//  AuthLibrarySPM
//
//  Created by Dionicio Cruz Velázquez on 3/10/25.
//

import SwiftUI
import Combine

@available(iOS 14.0, *)
@MainActor
public final class SettingsViewModel: ObservableObject {
    // MARK: Public properties
    @Published public var showError: Bool = false
    @Published public var errorMessage: String? = nil
    @Published public var authState: AuthState = .login
    public var preferences: FaceIDPreferencesProtocol
    public let authVM: AuthViewModel
    public var authManager: AuthManager { authVM.authManager }

    // MARK: Private properties
    private var cancellables = Set<AnyCancellable>()

    // MARK: Initializer
    public init(
        authViewModel: AuthViewModel,
        preferences: FaceIDPreferencesProtocol = FaceIDPreferencesManager()
    ) {
        self.authVM = authViewModel
        self.preferences = preferences
        bindAuthVM()
    }

    public convenience init(
        authManager: AuthManager,
        preferences: FaceIDPreferencesProtocol = FaceIDPreferencesManager()
    ) {
        self.init(authViewModel: AuthViewModel(authManager: authManager), preferences: preferences)
    }

    // MARK: - Public methods
    public func signOut() {
        authManager.signOut()
        preferences.hasLoggedOut = true
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
