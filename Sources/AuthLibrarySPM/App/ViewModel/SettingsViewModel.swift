//
//  File.swift
//  AuthLibrarySPM
//
//  Created by Dionicio Cruz Velázquez on 3/10/25.
//

import Combine
import SwiftUI

@available(iOS 13.0, *)
@MainActor
public class SettingsViewModel: AuthViewModel {
    
    public init() {
        super.init(authManager: AuthManager.shared)
    }

    public func signOut() {
        authManager.signOut()
    }
}
