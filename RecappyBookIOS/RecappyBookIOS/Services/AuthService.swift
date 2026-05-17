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
}
