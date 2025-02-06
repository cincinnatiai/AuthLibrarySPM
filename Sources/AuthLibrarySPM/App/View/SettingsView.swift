//
//  SettingsView.swift
//  Library
//
//  Created by Dionicio Cruz Velázquez on 2/5/25.
//

import SwiftUI

@available(iOS 14.0, *)
public struct SettingsView: View {
    @EnvironmentObject public var authManager: AuthManager

    public init() { }

    public var body: some View {
        VStack {
            Spacer()
            Text("Add more content")
            Spacer()
            Button("Sign Out", action: authManager.signOut)
                .buttonStyle()
                .padding()
            Spacer()
        }
    }
}

@available(iOS 14.0, *)
#Preview {
    SettingsView()
}
