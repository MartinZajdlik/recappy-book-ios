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
            
            UserDefaults.standard.set(response.token, forKey: "jwtToken")
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
        
        UserDefaults.standard.removeObject(forKey: "jwtToken")
        UserDefaults.standard.removeObject(forKey: "userRole")
        UserDefaults.standard.removeObject(forKey: "currentUsername")
        
        isLoggedIn = false
    }
    
    
    // MARK: - SESSION
    
    private func loadSession() {
        
        if let savedToken = UserDefaults.standard.string(forKey: "jwtToken") {
            
            token = savedToken
            role = UserDefaults.standard.string(forKey: "userRole")
            
            isLoggedIn = true
        }
    }
}
