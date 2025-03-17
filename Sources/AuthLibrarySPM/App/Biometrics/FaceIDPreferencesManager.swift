//
//  File.swift
//  AuthLibrarySPM
//
//  Created by Dionicio Cruz Velázquez on 3/13/25.
//

import Foundation
import SwiftUI

public protocol FaceIDPreferencesProtocol {
    var isFaceIDEnabled: Bool { get set }
    var isAppRelaunch: Bool { get set }
    var hasLoggedOut: Bool { get set }
}

@available(iOS 14.0, *)
public class FaceIDPreferencesManager: ObservableObject, FaceIDPreferencesProtocol {

    public init() {}

    @AppStorage("isFaceIDEnabled") public var isFaceIDEnabled = false
    @AppStorage("isAppRelaunch") public var isAppRelaunch = false
    @AppStorage("hasLoggedOut") public var hasLoggedOut = false
}
