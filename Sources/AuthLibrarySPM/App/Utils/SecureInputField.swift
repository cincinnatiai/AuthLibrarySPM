//
//  SecureInputField.swift
//  AuthLibrarySPM
//
//  Created by Noel Hiram Pat Angulo on 6/6/25.
//

import SwiftUI

@available(iOS 13.0, *)
struct SecureInputField: View {
    let title: String
    @Binding var text: String
    @State private var isNotSecure: Bool = false

    var body: some View {
        ZStack(alignment:  .trailing) {
            if isNotSecure  {
                TextField(title, text: $text)
                    .secureFieldStyle()
                    .autocapitalization(.none)
            } else {
                SecureField(title, text: $text)
                    .secureFieldStyle()
                    .autocapitalization(.none)
            }
            Button(action:  {
                isNotSecure.toggle()
            }) {
                Image(systemName: isNotSecure ? "eye.slash.fill" : "eye.fill")
                    .foregroundColor(.accentColor)
            }
            .padding()
            .buttonStyle(PlainButtonStyle())
        }
    }
}
