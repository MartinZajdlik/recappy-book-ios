//
//  RecappyBookIOSApp.swift
//  RecappyBookIOS
//
//  Created by Martin Žajdlík on 13.05.2026.
//

import SwiftUI

@main
struct RecappyBookIOSApp: App {
    
    @StateObject private var authViewModel = AuthViewModel()
    
    var body: some Scene {
        WindowGroup {
            
            if authViewModel.isLoggedIn {
                ContentView(authViewModel: authViewModel)
            } else {
                AuthView(viewModel: authViewModel)
            }
        }
    }
}
