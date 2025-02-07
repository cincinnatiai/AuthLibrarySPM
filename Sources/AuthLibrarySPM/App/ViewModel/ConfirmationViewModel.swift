//
//  ConfirmationViewModel.swift
//  Library
//
//  Created by Dionicio Cruz Velázquez on 2/5/25.
//

import SwiftUI

@available(iOS 13.0, *)
public class ConfirmationViewModel: AuthViewModel {
    @Published public var confirmationCode: String = ""
    var username: String
    
    public init(authManager: AuthManager, username: String) {
        self.username = username
        super.init(authManager: authManager)
    }
    
    public func confirmSignUp() {
        authManager.confirmSignUp(username: username, confirmationCode: confirmationCode)
        handleActionResult()
    }
}
