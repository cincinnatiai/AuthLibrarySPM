//
//  File.swift
//  AuthLibrarySPM
//
//  Created by Dionicio Cruz Velázquez on 3/10/25.
//

import Combine
import SwiftUI

@available(iOS 14.0, *)
@MainActor
public class SettingsViewModel: AuthViewModel {

    var preferences: FaceIDPreferencesProtocol
    
    public init(authManager: AuthManager, preferences: FaceIDPreferencesProtocol = FaceIDPreferencesManager()) {
        self.preferences = preferences
        super.init(authManager: authManager)
    }

    public func signOut() {
        authManager.signOut()
        preferences.hasLoggedOut = true
    }
}
