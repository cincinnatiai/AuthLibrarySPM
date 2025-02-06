//
//  StyleHelper.swift
//  Library
//
//  Created by Dionicio Cruz Velázquez on 2/5/25.
//

import SwiftUI

@available(iOS 13.0, *)
public struct TextFieldStyle: ViewModifier {
    public func body(content: Content) -> some View {
        content
            .autocapitalization(.none)
            .padding()
            .background(Color(.secondarySystemBackground))
            .cornerRadius(8.0)
    }
}

@available(iOS 13.0, *)
public struct SecureFieldStyle: ViewModifier {
    public func body(content: Content) -> some View {
        content
            .padding()
            .background(Color(.secondarySystemBackground))
            .cornerRadius(8.0)
    }
}

@available(iOS 13.0, *)
public struct ButtonStyle: ViewModifier {
    public func body(content: Content) -> some View {
        content
            .foregroundColor(.white)
            .padding()
            .padding(.horizontal, 40)
            .background(Color.blue)
            .cornerRadius(8.0)
            .textContentType(.password)
            .disableAutocorrection(true)
            .autocapitalization(.none)
    }
}

@available(iOS 13.0, *)
extension View {
    public func textFieldStyle() -> some View {
        self.modifier(TextFieldStyle())
    }

    public func secureFieldStyle() -> some View {
        self.modifier(SecureFieldStyle())
    }

    public func buttonStyle() -> some View {
        self.modifier(ButtonStyle())
    }
}

