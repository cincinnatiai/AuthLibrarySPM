//
//  File.swift
//  AuthLibrarySPM
//
//  Created by Trainee on 3/26/25.
//

import Foundation
import SwiftUI

@available(iOS 18.0, *)
public protocol BaseLoginView: View {
    var viewModel: LoginViewModel {get}
    
    func emailTextField() -> AnyView
    func passwordTextField() -> AnyView
    func loginButton() -> AnyView
    func errorMessageLabel() -> AnyView
    func faceIDToggle() -> AnyView
    func signUpButton() -> AnyView
    func clearErrorMessage()
}
