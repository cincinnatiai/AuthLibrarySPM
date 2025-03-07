//
//  LoginView.swift
//  Library
//
//  Created by Dionicio Cruz Velázquez on 2/5/25.
//

import SwiftUI

@available(iOS 14.0, *)
public struct LoginView: View {
    @StateObject private var viewModel: LoginViewModel
    @State private var isPasswordVisible: Bool = false

    init(viewModel: LoginViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    public var body: some View {
        VStack {
            Spacer()
            TextField("Email", text: $viewModel.email)
                .textFieldStyle()
                .keyboardType(.emailAddress)
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
                        .foregroundColor(.black)
                }
                .padding()
                .buttonStyle(PlainButtonStyle())
            }

            Button("Login", action: {
                viewModel.login()
            })
            .buttonStyle()

            viewModel.authManager.errorTextView

            Spacer()

            Button("Don't have an account? Sign up.", action: {
                viewModel.signUp()
            })
            .padding(.top, 20)
        }
        .padding()
        .padding(.horizontal, 15)
        .onAppear {
            viewModel.clearErrorMessage()
        }
    }
}

@available(iOS 14.0, *)
#Preview {
    LoginView(viewModel: LoginViewModel(authManager: AuthManager()))
}
