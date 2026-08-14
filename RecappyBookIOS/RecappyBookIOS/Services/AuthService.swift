import Foundation

final class AuthService {
    
    static let shared = AuthService()
    
    private init() {}
    
    private let baseURL = "https://recappy-book.onrender.com"
    
    
    // MARK: - LOGIN
    
    func login(username: String, password: String) async throws -> LoginResponse {
        
        guard let url = URL(string: "\(baseURL)/auth/login") else {
            throw URLError(.badURL)
        }
        
        let body = LoginRequest(
            username: username,
            password: password
        )
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(body)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }
        
        guard httpResponse.statusCode == 200 else {
            
            let errorMessage = String(data: data, encoding: .utf8) ?? "Neznámá chyba"
            
            throw NSError(
                domain: "",
                code: httpResponse.statusCode,
                userInfo: [
                    NSLocalizedDescriptionKey: errorMessage
                ]
            )
        }
        
        return try JSONDecoder().decode(LoginResponse.self, from: data)
    }
    
    
    // MARK: - REGISTER
    
    func register(username: String,
                  email: String,
                  password: String) async throws -> String {
        
        guard let url = URL(string: "\(baseURL)/auth/register") else {
            throw URLError(.badURL)
        }
        
        let body = RegisterRequest(
            username: username,
            email: email,
            password: password
        )
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(body)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }
        
        let message = String(data: data, encoding: .utf8) ?? ""
        
        guard httpResponse.statusCode == 200 else {
            throw NSError(
                domain: "",
                code: httpResponse.statusCode,
                userInfo: [
                    NSLocalizedDescriptionKey: message
                ]
            )
        }
        
        return message
    }
    // MARK: - FORGOT PASSWORD

    func forgotPassword(email: String) async throws {
        
        guard let url = URL(string: "\(baseURL)/auth/forgot") else {
            throw URLError(.badURL)
        }
        
        let body = ForgotPasswordRequest(email: email)
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(body)
        
        let (_, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }
        
        guard httpResponse.statusCode == 200 else {
            throw NSError(
                domain: "",
                code: httpResponse.statusCode,
                userInfo: [
                    NSLocalizedDescriptionKey: "Nepodařilo se odeslat reset hesla."
                ]
            )
        }
    }
    
    // MARK: - CURRENT USER

    func getCurrentUser() async throws -> UserInfoResponse {
        
        let request = try APIClient.shared.makeRequest(
            path: "/auth/me",
            method: "GET",
            requiresAuth: true
        )

        let (data, response) = try await APIClient.shared.send(request)

        guard response.statusCode == 200 else {
            throw NSError(
                domain: "",
                code: response.statusCode,
                userInfo: [
                    NSLocalizedDescriptionKey: "Neautorizováno."
                ]
            )
        }

        return try JSONDecoder().decode(UserInfoResponse.self, from: data)
    }
    
    func deleteMyAccount() async throws {

        let request = try APIClient.shared.makeRequest(
            path: "/auth/me",
            method: "DELETE",
            requiresAuth: true
        )

        let (_, response) = try await APIClient.shared.send(request)

        guard response.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
    }

    // MARK: - REFRESH TOKEN

    /// Vymění uložený refresh token za nový pár access/refresh tokenů (rotace na serveru)
    /// a rovnou je uloží do Keychainu. Volá se z `APIClient.send` při 401, proto jde přímo
    /// přes `URLSession`, aby nevznikla rekurze přes `send`.
    func refreshAccessToken() async throws -> String {

        guard let storedRefreshToken = KeychainService.shared.getRefreshToken() else {
            throw NSError(domain: "", code: 401, userInfo: [NSLocalizedDescriptionKey: "Nejsi přihlášen."])
        }

        guard let url = URL(string: "\(baseURL)/auth/refresh") else {
            throw URLError(.badURL)
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(RefreshRequest(refreshToken: storedRefreshToken))

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            KeychainService.shared.clearSession()
            throw NSError(domain: "", code: 401, userInfo: [NSLocalizedDescriptionKey: "Přihlášení vypršelo."])
        }

        let decoded = try JSONDecoder().decode(LoginResponse.self, from: data)

        KeychainService.shared.saveToken(decoded.token)
        KeychainService.shared.saveRefreshToken(decoded.refreshToken)

        return decoded.token
    }

    // MARK: - SERVER LOGOUT

    /// Best-effort odvolání refresh tokenu na serveru; chyby se ignorují, lokální
    /// odhlášení (smazání z Keychainu) proběhne v `AuthViewModel.logout()` vždy.
    func serverLogout() async {
        guard let storedRefreshToken = KeychainService.shared.getRefreshToken(),
              let url = URL(string: "\(baseURL)/auth/logout") else {
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONEncoder().encode(RefreshRequest(refreshToken: storedRefreshToken))

        _ = try? await URLSession.shared.data(for: request)
    }
}
