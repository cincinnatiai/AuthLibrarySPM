//
//  SignUpView.swift
//  Library
//
//  Created by Dionicio Cruz Velázquez on 2/5/25.
//

import SwiftUI

@available(iOS 14.0, *)
public struct SignUpView: View {
    let horizontalPadding : CGFloat = 15
    @StateObject private var viewModel: SignUpViewModel

    init(viewModel: SignUpViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    public var body: some View {
        VStack {
            Spacer()
            TextField("Email", text: $viewModel.email)
                .textFieldStyle()
                .keyboardType(.emailAddress)
            SecureInputField(title: "Password", text: $viewModel.password)
            SecureInputField(
                title: "Confirm Password",
                text: $viewModel.confirmPassword
            )

            Button("Sign Up", action: {
                viewModel.signUp()
            })
            .buttonStyle(isEnabled: viewModel.requirementsFulfilled())
            .disabled(!viewModel.requirementsFulfilled())

            if let firstRequirement = viewModel.signUpRequirements.first {
                Text(firstRequirement.text)
                    .fontWeight(.bold)
                    .foregroundColor(firstRequirement.isValid() ? .green : .red)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text("Password requirements:")
                    .fontWeight(.bold)

                ForEach(
                    viewModel.signUpRequirements.dropFirst(),
                    id: \.text
                ) { requirement in
                    HStack {
                        Text(requirement.text)
                            .foregroundColor(
                                requirement.isValid() ? .green : .red
                            )
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            viewModel.errorTextView

            Spacer()

            Button("Already have an account? Log in.", action: {
                viewModel.showLogin()
            })
        }
        .padding()
        .padding(.horizontal, horizontalPadding)
        .onAppear {
            viewModel.clearErrorMessage()
        }
    }
}
