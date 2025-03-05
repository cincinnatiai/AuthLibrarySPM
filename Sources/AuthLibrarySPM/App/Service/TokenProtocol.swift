//
//  TokenProtocol.swift
//  AuthLibrarySPM
//
//  Created by Dionicio Cruz Velázquez on 3/5/25.
//

import Foundation

public protocol TokenManagerProtocol: AnyObject {
    func manageTokenId(idToken: String)
}
