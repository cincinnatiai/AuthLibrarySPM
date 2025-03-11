//
//  File.swift
//  AuthLibrarySPM
//
//  Created by GenericDevCalifornia on 3/11/25.
//

import Foundation
import AuthLibrarySPM
import KeychainSwift

class MockKeychainValues: KeychainProtocol {
    public var keychain: [String : Any] = [:]

    func set(_ value: String, key: String) {
        keychain[key] = value
    }
    
    func get(key: String) -> String? {
        return keychain[key] as? String
    }
}
