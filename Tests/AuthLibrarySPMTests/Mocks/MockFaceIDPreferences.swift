//
//  File.swift
//  AuthLibrarySPM
//
//  Created by Dionicio Cruz Velázquez on 3/13/25.
//

import AuthLibrarySPM
import Foundation

class MockFaceIDPreferences: FaceIDPreferencesProtocol {
    var isAppRelaunch: Bool = false
    var hasLoggedOut: Bool = false
    var isFaceIDEnabled: Bool = false
}
