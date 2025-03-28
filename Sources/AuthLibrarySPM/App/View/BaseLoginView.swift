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
    var viewModel: LoginViewModel { get }
    var emailTextField: AnyView { get }
    var passwordTextField: AnyView { get }
    var loginButton: AnyView { get }
    var errorMessageLabel: AnyView { get }
    var faceIDToggle: AnyView { get }
    var signUpButton: AnyView { get }
    
    func clearErrorMessage()
}
