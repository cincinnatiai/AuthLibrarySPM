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
    
    init(viewModel: LoginViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    public var body: some View {
        VStack {
            Spacer()
            TextField("Email", text: $viewModel.email)
                .textFieldStyle()
                .keyboardType(.emailAddress)
            
            TextField("Password", text: $viewModel.password)
                .secureFieldStyle()
            
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
