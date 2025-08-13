//
//  LoginView.swift
//  Library
//
//  Created by Dionicio Cruz Velázquez on 2/5/25.
//

import SwiftUI

@available(iOS 17.0, *)
public struct LoginView: BaseLoginView {
    
    @StateObject public var viewModel: LoginViewModel
    @State private var isPasswordVisible: Bool = false
    
    public init(viewModel: LoginViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    public var body: some View {
        VStack {
            Spacer()
            emailTextField
            passwordTextField
            loginButton
            errorMessageLabel
            Spacer().frame(height: 30)
            if FeatureFlags.shared.isBiometricLoginEnabled{
                faceIDToggle
            }
            Spacer()
            signUpButton
        }
        .padding()
        .padding(.horizontal, 15)
        .onAppear {
            clearErrorMessage()
            Task { await viewModel.tryAutoLogin() }
        }
    }
    
    public var emailTextField: AnyView {
        AnyView (
            TextField(LocalizedStringKeys.GeneralEmailTextPlaceHolder, text: $viewModel.email)
                .textFieldStyle()
                .keyboardType(.emailAddress)
        )
    }
    
    public var passwordTextField: AnyView {
        AnyView (
            SecureInputField(title: LocalizedStringKeys.GeneralPasswordTexPlaceHolder, text: $viewModel.password)
        )
    }
    
    public var loginButton: AnyView {
        AnyView (
            Button(LocalizedStringKeys.GeneralLoginButton, action: {
                Task {
                    await viewModel.login()
                }
            })
            .buttonStyle()
        )
    }
    
    public var errorMessageLabel: AnyView {
        AnyView (
            viewModel.errorTextView
        )
    }
    
    public var faceIDToggle: AnyView {
        AnyView (
            Toggle(isOn: $viewModel.isFaceIDEnabled) {
                Image(systemName: LocalizedStringKeys.LoginViewFaceIDImageSystemName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 30, height: 30)
                    .foregroundColor(viewModel.isFaceIDEnabled ? .blue : .gray)
            }
                .onChange(of: viewModel.isFaceIDEnabled) { newValue in
                    Task {
                        await viewModel.toggleFaceID(newValue)
                    }
                }
                .padding(.horizontal, 100)
                .frame(maxWidth: .infinity, alignment: .center)
                .tint(.blue)
                .scaleEffect(0.8)
        )
    }
    
    public var signUpButton: AnyView {
        AnyView (
            Button(LocalizedStringKeys.LoginViewSignUpPrompt, action: {
                viewModel.signUp()
            })
            .padding(.top, 20)
        )
    }
    
    public func clearErrorMessage() {
        viewModel.clearErrorMessage()
    }
}

//@available(iOS 17.0, *)
//#Preview {
//    LoginView(viewModel: LoginViewModel(authManager: AuthManager(), preferences: FaceIDPreferencesManager()))
//}
