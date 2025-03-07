//
//  File.swift
//  AuthLibrarySPM
//
//  Created by GenericDevCalifornia on 3/4/25.
//

import Foundation

public protocol TokenManagerProtocol: AnyObject {
    func manageToken(idToken: String)
}
