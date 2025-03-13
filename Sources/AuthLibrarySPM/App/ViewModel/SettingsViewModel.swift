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

    var preferences: FaceIDPreferencesProtocol
    
    public init(preferences: FaceIDPreferencesProtocol = FaceIDPreferencesManager()) {
        self.preferences = preferences
        super.init(authManager: AuthManager.shared)
    }

    public func signOut() {
        authManager.signOut()
        preferences.hasLoggedOut = true
    }
}
