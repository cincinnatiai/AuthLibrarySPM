//
//  SessionView.swift
//  Library
//
//  Created by Dionicio Cruz Velázquez on 2/5/25.
//

import SwiftUI

@available(iOS 14.0, *)
public struct SessionView: View {
    @EnvironmentObject var authManager: AuthManager
    @StateObject private var viewModel: SessionViewModel
    
    public init(viewModel: SessionViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    public var body: some View {
        TabView {
            Text("Content of the first tab")
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("Home")
                }
            
            Text("Content of the second tab")
                .tabItem {
                    Image(systemName: "folder.fill")
                    Text("TODO")
                }
            
            Text("Content of the third tab")
                .tabItem {
                    Image(systemName: "folder.fill")
                    Text("TODO")
                }
            
            SettingsView()
                .tabItem {
                    Image(systemName: "gear")
                    Text("Settings")
                }
                .environmentObject(authManager)
        }
    }
}

@available(iOS 14.0, *)
#Preview {
    SessionView(viewModel: SessionViewModel(authManager: AuthManager(), user: "Dionicio"))
}

