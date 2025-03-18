//
//  File.swift
//  AuthLibrarySPM
//
//  Created by Dionicio Cruz Velázquez on 3/13/25.
//

import AuthLibrarySPM
import Foundation

class MockFaceIDAuthenticator: FaceIDAuthenticator {
    var shouldSucceed = true
    var simulateError: FaceIdError?
    var simulateUnkownError: Error?

    override func authenticate() async throws -> Bool {
        if let error = simulateError {
            throw error
        }
        if let unknownError = simulateUnkownError {
            throw unknownError
        }
        return shouldSucceed
    }
}
