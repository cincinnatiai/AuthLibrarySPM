//
//  File.swift
//  AuthLibrarySPM
//
//  Created by GenericDevCalifornia on 3/7/25.
//

import Foundation
import AuthLibrarySPM

class MockTokenHandler: TokenManagerProtocol {
    var idToken: String?
    var accessToken: String?
    var refreshToken: String?

    func getIdToken() -> String? {
        return idToken
    }

    func manageTokenId(idToken: String) {
        self.idToken = idToken
    }

    func getAccessToken() -> String? {
        return accessToken
    }

    func manageAccessToken(accessToken: String) {
        self.accessToken = accessToken
    }

    func getRefreshToken() -> String? {
        return refreshToken
    }

    func manageRefreshToken(refreshToken: String) {
        self.refreshToken = refreshToken
    }

    func getNewTokens() -> (idToken: String?, accessToken: String?) {
        return (idToken, accessToken)
    }

    func manageNewTokens(idToken: String, accessToken: String) {
        self.idToken = idToken
        self.accessToken = accessToken
    }

    func clearAllTokens() {
        idToken = nil
        accessToken = nil
        refreshToken = nil
    }
}
