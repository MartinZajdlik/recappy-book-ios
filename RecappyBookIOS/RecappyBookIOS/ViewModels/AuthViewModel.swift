import Foundation
import Combine

@MainActor
final class AuthViewModel: ObservableObject {
    
    @Published var username = ""
    @Published var password = ""
    @Published var email = ""
    
    @Published var isLoggedIn = false
    @Published var isLoading = false
    
    @Published var errorMessage = ""
    @Published var successMessage = ""
    
    @Published var token: String? = nil
    @Published var role: String? = nil
    
    
    init() {
        loadSession()
    }
    
    
    // MARK: - LOGIN
    
    func login() async {
        
        errorMessage = ""
        successMessage = ""
        
        isLoading = true
        
        defer {
            isLoading = false
        }
        
        do {
            
            let response = try await AuthService.shared.login(
                username: username,
                password: password
            )
            
            token = response.token
            role = response.role
            
            KeychainService.shared.saveToken(response.token)
            UserDefaults.standard.set(response.role, forKey: "userRole")
            UserDefaults.standard.set(username, forKey: "currentUsername")
            
            isLoggedIn = true
            
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    
    // MARK: - REGISTER
    
    func register() async {
        
        errorMessage = ""
        successMessage = ""
        
        isLoading = true
        
        defer {
            isLoading = false
        }
        
        do {
            
            let message = try await AuthService.shared.register(
                username: username,
                email: email,
                password: password
            )
            
            successMessage = message
            
            username = ""
            email = ""
            password = ""
            
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    // MARK: - FORGOT PASSWORD

    func forgotPassword() async {
        
        errorMessage = ""
        successMessage = ""
        isLoading = true
        
        defer {
            isLoading = false
        }
        
        do {
            try await AuthService.shared.forgotPassword(email: email)
            successMessage = "Pokud e-mail existuje, poslali jsme odkaz pro reset hesla."
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    
    // MARK: - LOGOUT
    
    func logout() {
        
        token = nil
        role = nil
        
        username = ""
        password = ""
        email = ""
        
        errorMessage = ""
        successMessage = ""
        
        KeychainService.shared.deleteToken()
        UserDefaults.standard.removeObject(forKey: "userRole")
        UserDefaults.standard.removeObject(forKey: "currentUsername")
        
        isLoggedIn = false
    }
    
    
    // MARK: - SESSION
    
    private func loadSession() {
        
        guard let savedToken = KeychainService.shared.getToken() else {
            return
        }
        
        token = savedToken
        
        Task {
            do {
                
                let user = try await AuthService.shared.getCurrentUser()
                
                role = user.role
                
                UserDefaults.standard.set(user.username, forKey: "currentUsername")
                UserDefaults.standard.set(user.role, forKey: "userRole")
                
                isLoggedIn = true
                
            } catch {
                
                logout()
            }
        }
    }
    
    func deleteMyAccount() async {
        errorMessage = ""
        
        do {
            try await AuthService.shared.deleteMyAccount()
            logout()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
