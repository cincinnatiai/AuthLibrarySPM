//
//  TokenProtocol.swift
//  AuthLibrarySPM
//
//  Created by Dionicio Cruz Velázquez on 3/5/25.
//

import Foundation

public protocol TokenManagerProtocol: AnyObject {
    func manageTokenId(idToken: String)
    func manageRefreshToken(refreshToken: String)
    func manageAccessToken(accessToken: String)
    func clearAllTokens()
}
