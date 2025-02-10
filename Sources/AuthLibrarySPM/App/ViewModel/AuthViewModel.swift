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
public class AuthViewModel: ObservableObject {
    @Published public var showError: Bool = false
    public let authManager: AuthManager
    
    private var cancellables = Set<AnyCancellable>()
    
    public init(authManager: AuthManager) {
        self.authManager = authManager
        observeErrorMessage()
    }
    
    public func clearErrorMessage() {
        authManager.clearErrorMessage()
        showError = false
    }
    
    private func observeErrorMessage() {
        authManager.$errorMessage
            .receive(on: DispatchQueue.main)
            .sink { [weak self] errorMessage in
                self?.showError = (errorMessage != nil)
            }
            .store(in: &cancellables)
    }
    
    public func handleActionResult() {
        showError = authManager.errorMessage != nil
    }
    
}
