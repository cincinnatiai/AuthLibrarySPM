//
//  SignUpView.swift
//  Library
//
//  Created by Dionicio Cruz Velázquez on 2/5/25.
//

import SwiftUI

@available(iOS 14.0, *)
public struct SignUpView: View {
    public let horizontalPadding: CGFloat = 15
    @ObservedObject public var viewModel: SignUpViewModel

    public init(viewModel: SignUpViewModel) {
        self._viewModel = ObservedObject(wrappedValue: viewModel)
    }

    public var body: some View {
        VStack {
            Spacer()
            TextField(LocalizedStringKeys.GeneralEmailTextPlaceHolder, text: $viewModel.email)
                .textFieldStyle()
                .keyboardType(.emailAddress)

            SecureInputField(title: LocalizedStringKeys.SignUpViewConfirmPasswordPlaceHolder,
                             text: $viewModel.password)

            SecureInputField(title: LocalizedStringKeys.SignUpViewConfirmPasswordPlaceHolder,
                             text: $viewModel.confirmPassword)

            Button(LocalizedStringKeys.GeneralSignUpButton) {
                viewModel.signUp()
            }
            .buttonStyle(isEnabled: viewModel.requirementsFulfilled())
            .disabled(!viewModel.requirementsFulfilled())

            if let first = viewModel.signUpRequirements.first {
                Text(first.text)
                    .fontWeight(.bold)
                    .foregroundColor(first.isValid() ? .green : .red)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(LocalizedStringKeys.SignUpViewPasswordRequirementsLabel.localizedCapitalized)
                    .fontWeight(.bold)

                ForEach(viewModel.signUpRequirements.dropFirst(), id: \.text) { req in
                    HStack {
                        Text(req.text)
                            .foregroundColor(req.isValid() ? .green : .red)
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            viewModel.errorTextView

            Spacer()

            Button(LocalizedStringKeys.SignUpViewAccountExistsPrompt.localizedCapitalized) {
                viewModel.showLogin()
            }
        }
        .padding()
        .padding(.horizontal, horizontalPadding)
        .onAppear {
            viewModel.clearErrorMessage()
        }
    }
}
