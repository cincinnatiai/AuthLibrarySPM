//
//  SessionViewModel.swift
//  Library
//
//  Created by Dionicio Cruz Velázquez on 2/5/25.
//

import SwiftUI

@available(iOS 13.0, *)
public class SessionViewModel: AuthViewModel {
    @Published public var user: String
    
    public init(authManager: AuthManager, user: String) {
        self.user = user
        super.init(authManager: authManager)
    }
    
    public func logout() {
        authManager.signOut()
    }
}
