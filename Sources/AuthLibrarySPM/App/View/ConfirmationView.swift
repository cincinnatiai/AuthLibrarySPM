//
//  ConfirmationView.swift
//  Library
//
//  Created by Dionicio Cruz Velázquez on 2/5/25.
//

import SwiftUI

@available(iOS 14.0, *)
public struct ConfirmationView: View {
    @StateObject private var viewModel: ConfirmationViewModel

    init(viewModel: ConfirmationViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    public var body: some View {
        VStack {
            Text(LocalizedStringKeys.UserNameText + viewModel.username)
            TextField(LocalizedStringKeys.ConfirmationCodeTextField, text: $viewModel.confirmationCode)
                .textFieldStyle()
            Button(LocalizedStringKeys.ConfirmButtonText, action: {
                viewModel.confirmSignUp()
            })
            .buttonStyle()

            viewModel.errorTextView
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
    ConfirmationView(viewModel: ConfirmationViewModel(authManager: AuthManager(), username: LocalizedStringKeys.UserNamePreviewText))
}
