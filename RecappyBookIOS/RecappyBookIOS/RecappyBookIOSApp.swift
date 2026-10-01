//
//  RecappyBookIOSApp.swift
//  RecappyBookIOS
//
//  Created by Martin Žajdlík on 13.05.2026.
//

import SwiftUI
import UIKit

@main
struct RecappyBookIOSApp: App {
    
    @StateObject private var authViewModel = AuthViewModel()
    
    init() {
        // Načítací kolečko při stažení seznamu dolů – výchozí šedá na tmavém pozadí zaniká.
        UIRefreshControl.appearance().tintColor = UIColor(AppTheme.green)
    }
    
    var body: some Scene {
        WindowGroup {
            
            if authViewModel.isLoggedIn {

                if authViewModel.role == "ROLE_ADMIN" {
                    AdminView(authViewModel: authViewModel)
                } else {
                    ContentView(authViewModel: authViewModel)
                }

            } else if authViewModel.isGuest {

                ContentView(authViewModel: authViewModel)

            } else {
                AuthView(viewModel: authViewModel)
            }
        }
    }
}
