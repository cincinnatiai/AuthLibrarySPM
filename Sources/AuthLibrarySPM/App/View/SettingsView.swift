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
    @State private var isBiometricEnabled: Bool = FeatureFlags.shared.isBiometricLoginEnabled
    
    public init() { }
    
    public var body: some View {
        VStack {
            Spacer()
            Toggle("Biometric Login Feature", isOn: $isBiometricEnabled)
                .padding()
                .onChange(of: isBiometricEnabled) { newValue in
                    FeatureFlags.shared.setBiometricEnabled(newValue)
                }
            Text(FeatureFlags.shared.isBiometricLoginEnabled
                 ? "Biometric Login is enabled"
                 : "Biometric Login is disabled")
            .font(.subheadline)
            .padding(.bottom, 8)
            Button(LocalizedStringKeys.GeneralSignOutButton, action: authManager.signOut)
                .buttonStyle()
                .padding()
            Spacer()
                .onAppear {
                    isBiometricEnabled = FeatureFlags.shared.isBiometricLoginEnabled
                }
        }
    }
}

@available(iOS 14.0, *)
#Preview {
    SettingsView()
}
