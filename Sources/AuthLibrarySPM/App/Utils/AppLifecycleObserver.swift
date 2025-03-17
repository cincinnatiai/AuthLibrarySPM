//
//  AppLifecycleObserver.swift
//  AuthLibrarySPM
//
//  Created by Dionicio Cruz Velázquez on 3/17/25.
//

import Foundation
import SwiftUI
import UIKit

@available(iOS 14.0, *)
public class AppLifecycleObserver: ObservableObject {
    @AppStorage("isAppRelaunch") private var isAppRelaunch = false
    
    public init() {
        addObservers()
    }
    
    private func addObservers() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleWillResignActive),
            name: UIApplication.willResignActiveNotification,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleDidBecomeActive),
            name: UIApplication.didBecomeActiveNotification,
            object: nil
        )
    }
    
    @objc private func handleWillResignActive() {
        self.isAppRelaunch = true
    }
    
    @objc private func handleDidBecomeActive() {
        self.isAppRelaunch = false
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
