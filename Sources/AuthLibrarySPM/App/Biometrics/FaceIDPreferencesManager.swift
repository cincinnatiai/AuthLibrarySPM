//
//  File.swift
//  AuthLibrarySPM
//
//  Created by Dionicio Cruz Velázquez on 3/13/25.
//

import Foundation

public protocol FaceIDPreferencesProtocol {
    var isFaceIDEnabled: Bool { get set }
    var isAppRelaunch: Bool { get set }
    var hasLoggedOut: Bool { get set }
}

public class FaceIDPreferencesManager: FaceIDPreferencesProtocol {
    private let defaults = UserDefaults.standard

    public init() {}

    public var isFaceIDEnabled: Bool {
        get { defaults.bool(forKey: "isFaceIDEnabled") }
        set { defaults.set(newValue, forKey: "isFaceIDEnabled") }
    }

    public var isAppRelaunch: Bool {
        get { defaults.bool(forKey: "isAppRelaunch") }
        set { defaults.set(newValue, forKey: "isAppRelaunch") }
    }

    public var hasLoggedOut: Bool {
        get { defaults.bool(forKey: "hasLoggedOut") }
        set { defaults.set(newValue, forKey: "hasLoggedOut") }
    }
}
