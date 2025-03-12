//
//  File.swift
//  AuthLibrarySPM
//
//  Created by GenericDevCalifornia on 3/7/25.
//

import Foundation
import AuthLibrarySPM

class MockTokenHandler: TokenManagerProtocol {
    var token: String?

    func manageTokenId(idToken: String) {
        self.token = idToken
    }
}
