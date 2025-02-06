//
//  ExampleApp.swift
//  AuthenticationLibrary_Tests
//
//  Created by Dionicio Cruz Velázquez on 2/6/25.
//  Copyright © 2025 CocoaPods. All rights reserved.
//

import SwiftUI

@available(iOS 14.0, *)
//@main
struct TestAppApp: App {
    @StateObject var authManager = AuthManager()
    var body: some Scene {
        WindowGroup {
            /// Can override the library's SessionView file, to provide your own implementation
            AuthApp()
            .environmentObject(authManager)
            .onAppear {
                authManager.initializeAWS()
                authManager.checkUserState()
            }
        }
    }
}
