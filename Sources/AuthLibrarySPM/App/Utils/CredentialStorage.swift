//
//  CredentialStorage.swift
//  Library
//
//  Created by Dionicio Cruz Velázquez on 2/5/25.
//

import Foundation
import KeychainSwift

final public class KeychainManager {
    public let keychain: KeychainSwift
    
    public init() {
        self.keychain = KeychainSwift()
        keychain.synchronizable = true
    }
    
    public func set(_ value: String, key: String) {
        keychain.set(value, forKey: key, withAccess: .accessibleAfterFirstUnlock)
    }
    
    public func get(key: String) -> String? {
        return keychain.get(key)
    }
}
