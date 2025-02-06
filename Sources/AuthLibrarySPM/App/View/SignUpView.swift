//
//  SignUpView.swift
//  Library
//
//  Created by Dionicio Cruz Velázquez on 2/5/25.
//

import SwiftUI

@available(iOS 14.0, *)
public struct SignUpView: View {
    @StateObject private var viewModel: SignUpViewModel
    
    init(viewModel: SignUpViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    public var body: some View {
        VStack {
            Spacer()
            TextField("Email", text: $viewModel.email)
                .textFieldStyle()
            TextField("Password", text: $viewModel.password)
                .secureFieldStyle()
            TextField("Confirm Password", text: $viewModel.confirmPassword)
                .secureFieldStyle()
            Button("Sign Up", action: {
                viewModel.signUp()
            })
            .buttonStyle()
            
            viewModel.authManager.errorTextView
            
            Spacer()
            
            Button("Already have an account? Log in.", action: {
                viewModel.showLogin()
            })
        }
        .padding()
        .padding(.horizontal, 15)
        .onAppear {
            viewModel.clearErrorMessage()
        }
    }
}
