//
//  CredentialStorage.swift
//  Library
//
//  Created by Dionicio Cruz Velázquez on 2/5/25.
//

import Foundation
import KeychainSwift

public protocol KeychainProtocol {
    func set(_ value: String, key: String)
    func get(key: String) -> String?
}

final public class KeychainManager: KeychainProtocol {
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
