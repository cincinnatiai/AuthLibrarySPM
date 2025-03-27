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
            emailTextField()
            passwordTextField()
            loginButton()
            errorMessageLabel()
            Spacer().frame(height: 30)
            faceIDToggle()
            Spacer()
            signUpButton()
        }
        .padding()
        .padding(.horizontal, 15)
        .onAppear {
            clearErrorMessage()
            Task { await viewModel.tryAutoLogin() }
        }
    }
    
    public func emailTextField() -> AnyView {
        AnyView (
            TextField("Email", text: $viewModel.email)
                .textFieldStyle()
                .keyboardType(.emailAddress)
        )
    }
    
    public func passwordTextField() -> AnyView {
        AnyView (
            ZStack(alignment:  .trailing) {
                if isPasswordVisible  {
                    TextField("Password", text: $viewModel.password)
                        .secureFieldStyle()
                        .autocapitalization(.none)
                } else {
                    SecureField("Password", text: $viewModel.password)
                        .secureFieldStyle()
                        .autocapitalization(.none)
                }
                Button(action:  {
                    isPasswordVisible.toggle()
                }) {
                    Image(systemName: isPasswordVisible ? "eye.slash.fill" : "eye.fill")
                        .foregroundColor(.accentColor)
                }
                .padding()
                .buttonStyle(PlainButtonStyle())
            }
        )
    }
    
    public func loginButton() -> AnyView {
        AnyView (
            Button("Login", action: {
                Task {
                    await viewModel.login()
                }
            })
            .buttonStyle()
        )
    }
    
    public func errorMessageLabel() -> AnyView {
        AnyView (
            viewModel.authManager.errorTextView
        )
    }
    
    public func faceIDToggle() -> AnyView {
        AnyView (
            Toggle(isOn: $viewModel.isFaceIDEnabled) {
                Image(systemName: "faceid")
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
    
    public func signUpButton() -> AnyView {
        AnyView (
            Button("Don't have an account? Sign up.", action: {
                viewModel.signUp()
            })
            .padding(.top, 20)
        )
    }
    
    public func clearErrorMessage() {
        viewModel.clearErrorMessage()
    }
}

@available(iOS 17.0, *)
#Preview {
    LoginView(viewModel: LoginViewModel(authManager: AuthManager(), preferences: FaceIDPreferencesManager()))
}
